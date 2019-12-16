#!/bin/bash

CLUSTER_NAME=chrisc-test
REGION=us-east-2
INSTANCE_IP_ADDR=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`
DEFAULT_VOLUME=`curl http://169.254.169.254/latest/meta-data/block-device-mapping/ebs1`

## AWS CLI Install
sudo apt update
sudo apt install awscli
sudo apt install jq
aws configue --profile
#aws configure

## Discover Volumes in Rebuilding Stage for current cluster
VOLUMES=$(aws ec2 describe-volumes --region $REGION --filters Name=tag-key,Values=["Name"] Name=tag-value,Values=["$CLUSTER_NAME"]  Name=tag-key,Values=["Status"] Name=tag-value,Values=["Rebuilding"] Name=status,Values=["available"] | jq '.Volumes[] | .VolumeId')

## Get first volume that's needed for rebuilding
if [[ -n $VOLUMES ]]; then

  SAVED_VOLUME=`echo $VOLUMES | cut -d' ' -f1`

  ## IF a Saved Volume exists, remove the default and add the Saved Volume to the instance
  if [[ -n $SAVED_VOLUME ]]; then
    aws ec2 detach-volume --volume-id $DEFAULT_VOLUME
    aws ec2 delete-volume --volume-id $DEFAULT_VOLUME
    aws ec2 create-tags --resources $SAVED_VOLUME --tags Key=Status,Value=Attaching
    aws ec2 attach-volume --resources $SAVED_VOLUME
  fi


## Format the new / default Volume
else

  sudo mkfs -t xfs /dev/xvdb

fi

## Mount the Volume
sudo mkdir /data
chmod 777 /data
sudo mount /dev/xvdb /data

## Install CockroachDB
wget -qO- https://binaries.cockroachdb.com/cockroach-v19.2.1.linux-amd64.tgz | tar  xvz
sudo cp -i cockroach-v19.2.1.linux-amd64/cockroach /usr/local/bin/

# Start Cockroach, join cluster
cockroach start --insecure --advertise-addr=localhost:26257 --store=/data —background
