#!/bin/bash
#
# インスタンス起動時に実行されるスクリプト
#

# ディスクをマウント
mount /dev/sdb /var/lib/docker/volumes

# ECSエージェントを起動
docker run --name ecs-agent \
    --detach=true \
    --restart=on-failure:10 \
    --volume=/var/run:/var/run \
    --volume=/var/log/ecs/:/log \
    --volume=/var/lib/ecs/data:/data \
    --volume=/etc/ecs:/etc/ecs \
    --net=host \
    --env-file=/etc/ecs/ecs.config \
    amazon/amazon-ecs-agent:latest
