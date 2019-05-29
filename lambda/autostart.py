import boto3 # (AWS SDK)

# Boto Connection
ec2 = boto3.resource('ec2', 'ap-northeast-1')

# 다음 조건에 맞는 EC2 인스턴스를 시작한다.
# 조건: "AutoStop" 태그의 값이 "true"이고 상태가 "stopped"
def lambda_handler(event, context):
  # Filters
  filters = [{
      'Name': 'tag:AutoStop',
      'Values': ['true']
    },
    {
      'Name': 'instance-state-name', 
      'Values': ['stopped']
    }
  ]

  # Filter running instances that should stop
  instances = ec2.instances.filter(Filters=filters)

  # Retrieve instance IDs
  instance_ids = [instance.id for instance in instances]

  # stopping instances
  stopping_instances = ec2.instances.filter(InstanceIds=instance_ids).start()