resource "aws_instance" "db" {
  ami                    = "ami-0d4cb7ae9a06c40c9"
  instance_type          = "t3.micro"
  key_name               = "XXXX"
  vpc_security_group_ids = [aws_security_group.db.id]
  subnet_id              = aws_subnet.default.id

  user_data = data.cloudinit_config.db.rendered

  iam_instance_profile = aws_iam_instance_profile.db.name

  private_ip = var.db_private_ip

  tags = {
    Name = "${var.project_name}_db"
  }
}

data "cloudinit_config" "db" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content      = local.cloud_config_content_db
  }
}

locals {
  cloud_config_content_db = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/var/lib/cloud/scripts/per-once/once.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = base64encode(data.template_file.init_script_db.rendered)
    },
    {
      path        = "/var/lib/cloud/scripts/per-boot/boot.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = base64encode(data.template_file.boot_script_db.rendered)
    },
  ]
})}
END
}

data "template_file" "init_script_db" {
  template = file("./init_scripts/db.sh")
  vars = {
    project_name = var.project_name
  }
}

data "template_file" "boot_script_db" {
  template = file("./boot_scripts/db.sh")
  vars = {
    project_name = var.project_name
  }
}

resource "aws_eip" "db" {
  instance = aws_instance.db.id

  tags = {
    Name = "${var.project_name}_db"
  }
}

resource "aws_volume_attachment" "db" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.db.id
  instance_id = aws_instance.db.id
}

resource "aws_ebs_volume" "db" {
  availability_zone = "ap-northeast-1a"
  size              = 10

  tags = {
    Name = "${var.project_name}_db"
  }
}

resource "aws_security_group" "db" {
  name   = "${var.project_name}_db"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}_db"
  }
}

resource "aws_iam_instance_profile" "db" {
  name = "${var.project_name}_db"
  role = aws_iam_role.instance_role_db.name
}

//
// ハードウェアの障害が発生した場合に自動復旧を行う
//
resource "aws_cloudwatch_metric_alarm" "db_recover" {
  alarm_name = "${var.project_name}_db_recover"

  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "2"
  evaluation_periods  = "2"
  threshold           = "0"

  metric_name = "StatusCheckFailed_System"
  namespace   = "AWS/EC2"
  period      = 60
  statistic   = "Minimum"
  dimensions = {
    "InstanceId" = aws_instance.db.id
  }

  alarm_actions = [
    "arn:aws:automate:ap-northeast-1:ec2:recover",
  ]
}

//
// インスタンスに障害が発生した場合に再起動を行う
//
resource "aws_cloudwatch_metric_alarm" "db_reboot" {
  alarm_name = "${var.project_name}_db_reboot"

  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "2"
  evaluation_periods  = "2"
  threshold           = "0"

  metric_name = "StatusCheckFailed_Instance"
  namespace   = "AWS/EC2"
  period      = 60
  statistic   = "Minimum"
  dimensions = {
    "InstanceId" = aws_instance.db.id
  }

  alarm_actions = [
    "arn:aws:automate:ap-northeast-1:ec2:reboot",
  ]
}

//
// インスタンスにロールを付与
//
resource "aws_iam_role" "instance_role_db" {
  name               = "${var.project_name}_instance_role_db"
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

resource "aws_iam_role_policy" "instance_role_db" {
  name   = "${var.project_name}_instance_role_db"
  role   = aws_iam_role.instance_role_db.id
  policy = data.aws_iam_policy_document.instance_role_db.json
}

data "aws_iam_policy_document" "instance_role_db" {
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
