#!/bin/bash

CLUSTER_NAME=chrisc-test
REGION=us-east-2
INSTANCE_IP_ADDR=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`
DEFAULT_VOLUME=`curl http://169.254.169.254/latest/meta-data/block-device-mapping/ebs1`

cockroach quit --insecure
sudo umount /dev/xvdb
aws ec2 detach-volume --volume-id $DEFAULT_VOLUME
aws ec2 create-tags --resources $DEFAULT_VOLUME --tags Key=Status,Value=Rebuilding
aws ec2 create-tags --resources $DEFAULT_VOLUME --tags Key=Name,Value=$CLUSTER_NAME
