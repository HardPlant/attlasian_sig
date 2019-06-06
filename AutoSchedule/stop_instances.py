#-*- coding: utf-8 -*-
import boto3 # (AWS SDK)

# Boto Connection
ec2 = boto3.resource('ec2', 'ap-northeast-1')

# AWS Lambda 함수 (월 100만 call까지 무료)
#
# 다음 조건에 맞는 EC2 인스턴스를 중단한다.
# 조건: "AutoStop" 태그의 값이 "true"이고 상태가 "running"
def lambda_handler(event, context):
  # Filters
  filters = [{
      'Name': 'tag:AutoStop',
      'Values': ['true']
    },
    {
      'Name': 'instance-state-name', 
      'Values': ['running']
    }
  ]

  # Filter running instances that should stop
  instances = ec2.instances.filter(Filters=filters)

  # Retrieve instance IDs
  instance_ids = [instance.id for instance in instances]

  # stopping instances
  stopping_instances = ec2.instances.filter(InstanceIds=instance_ids).stop()