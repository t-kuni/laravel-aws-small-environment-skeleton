resource "aws_instance" "app" {
  ami                    = "ami-0d4cb7ae9a06c40c9"
  instance_type          = "t3.micro"
  key_name               = "XXXX"
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id              = aws_subnet.default.id

  user_data = data.cloudinit_config.app.rendered

  iam_instance_profile = aws_iam_instance_profile.app.name

  tags = {
    Name = "${var.project_name}_app"
  }
}

data "cloudinit_config" "app" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content      = local.cloud_config_content_app
  }
}

locals {
  cloud_config_content_app = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/var/lib/cloud/scripts/per-once/once.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = base64encode(data.template_file.init_script_app.rendered)
    },
    {
      path        = "/var/lib/cloud/scripts/per-boot/boot.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = base64encode(data.template_file.boot_script_app.rendered)
    },
  ]
})}
END
}

data "template_file" "init_script_app" {
  template = file("./init_scripts/app.sh")
  vars = {
    project_name = var.project_name
  }
}

data "template_file" "boot_script_app" {
  template = file("./boot_scripts/app.sh")
  vars = {
    project_name = var.project_name
  }
}

resource "aws_eip" "app" {
  instance = aws_instance.app.id

  tags = {
    Name = "${var.project_name}_app"
  }
}

resource "aws_security_group" "app" {
  name   = "${var.project_name}_app"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}_app"
  }
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}_app"
  role = aws_iam_role.instance_role_app.name
}

//
// ハードウェアの障害が発生した場合に自動復旧を行う
//
resource "aws_cloudwatch_metric_alarm" "app_recover" {
  alarm_name = "${var.project_name}_app_recover"

  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "2"
  evaluation_periods  = "2"
  threshold           = "0"

  metric_name = "StatusCheckFailed_System"
  namespace   = "AWS/EC2"
  period      = 60
  statistic   = "Minimum"
  dimensions = {
    "InstanceId" = aws_instance.app.id
  }

  alarm_actions = [
    "arn:aws:automate:ap-northeast-1:ec2:recover",
  ]
}

//
// インスタンスに障害が発生した場合に再起動を行う
//
resource "aws_cloudwatch_metric_alarm" "app_reboot" {
  alarm_name = "${var.project_name}_app_reboot"

  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "2"
  evaluation_periods  = "2"
  threshold           = "0"

  metric_name = "StatusCheckFailed_Instance"
  namespace   = "AWS/EC2"
  period      = 60
  statistic   = "Minimum"
  dimensions = {
    "InstanceId" = aws_instance.app.id
  }

  alarm_actions = [
    "arn:aws:automate:ap-northeast-1:ec2:reboot",
  ]
}

//
// インスタンスにロールを付与
//
resource "aws_iam_role" "instance_role_app" {
  name               = "${var.project_name}_instance_role_app"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "instance_role_app" {
  name   = "${var.project_name}_instance_role_app"
  role   = aws_iam_role.instance_role_app.id
  policy = data.aws_iam_policy_document.instance_role_app.json
}

data "aws_iam_policy_document" "instance_role_app" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeTags",
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
}
