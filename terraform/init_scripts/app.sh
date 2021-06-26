#!/bin/bash
#
# インスタンス作成時に一度だけ実行されるスクリプト
#

# ECSクラスタと紐づけ
echo ECS_CLUSTER=${project_name}_app >> /etc/ecs/ecs.config
