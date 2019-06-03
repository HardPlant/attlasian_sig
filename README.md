# Attlassian Sig

### 키 페어 생성

* 자동화기 전에 EC2 쉘에 생성할 키 페어를 만들어야 한다.

```
ssh-keygen -y -f ConfluenceJira.pem > id_rsa.pub
```

* 이 명령어는 

### 인프라 생성

t3.small 인스턴스 2개와 CloudWatch를 사용하도록 한다.

##### Terraform 초기화

AWS IAM에서 아이디를 하나 발급받아 `aws configure`로 액세스 ID를 설정한다.

`terraform init` 명령어로 해당 폴더에 terraform 설정을 만든다.

`terraform apply` 명령어로 상태를 갱신한다. (변경 사항을 자동으로 반영함)

`terraform show` 명령어로 클라우드 자원의 현재 상태를 확인한다.

##### 도메인 추가

* Route53, EIP를 이용해 EC2 인스턴스와 연결할 도메인을 생성한다.

```t
#####################
# 도메인 이름을 설정한다.
#####################
resource "aws_route53_zone" "main" {
  name = "themirai.net"
}

# jira 서브도메인을 설정한다.
resource "aws_route53_zone" "jira" {
  name = "jira.themirai.net"

  tags = {
    Environment = "jira"
  }
}

# Simple Routing으로, 도메인과 IP를 즉시 연결한다.
# ELB를 사용하지 않으므로, https를 직접 설정해주어야 한다.

resource "aws_route53_record" "jira-ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "jira.themirai.net"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_eip.jira.public_ip}",
  ]
}

# Confluence 서브도메인을 설정한다.
resource "aws_route53_zone" "confluence" {
  name = "confluence.themirai.net"

  tags = {
    Environment = "confluence"
  }
}

resource "aws_route53_record" "confluence-ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "confluence.themirai.net"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_eip.confluence.public_ip}",
  ]
}
#################################################
# Confluence, Jira 도메인 이름과 연동할 EIP를 가져온다.
#################################################

resource "aws_eip" "confluence" {
  instance = "${aws_instance.confluence.id}"
  vpc      = true
}

resource "aws_eip" "jira" {
  instance = "${aws_instance.jira.id}"
  vpc      = true
}
```
##### 네트워킹

VPC를 이용해 가상 내부망을 생성하고, 해당 내부망을 인터넷과 연결한다.
또한 방화벽을 설정해 포트를 열어준다.

```t

# VPC : 가상 내부망을 하나 설정한다.
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Grant the VPC internet access on its main route table
# Default Gateway : 내부망의 게이트웨이를 설정한다.
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

##### 인스턴스 생성 및 Provisioner 설정

EC2 인스턴스를 추가하고 인스턴스 생성 후 즉시 실행할 스크립트를 설정한다.

[참고자료](https://www.terraform.io/intro/examples/aws.html)

###### local-exec

* local-exec

terraform을 실행 중인 local machine에 명령이 실행된다.
다음 명령어는 메타데이터 중 `public_ip`를 현재 폴더에 `txt`로 출력한다.

```t
resource "aws_instance" "jira" {
    ami     = "ami-08ab3f7e72215fe91" # Amazon Linux 2 AMI (HVM), SSD Volume Type
    instance_type = "t2.micro"

    provisioner "local-exec" {
        command = "echo ${aws_instance.confluence.public_ip} > ip_address_confluence.txt"
    }
}
```

* remote-exec

원격 머신에서 실행한다.

```t
connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
}

# We run a remote provisioner on the instance after creating it.
# In this case, we just install nginx and start it. By default,
# this should be on port 80
provisioner "remote-exec" {
    inline = [
        "sudo apt-get -y update",
        "sudo apt-get -y install nginx",
        "sudo service nginx start",
    ]
}
```

##### EBS 추가

```t
# SSD 부착

resource "aws_volume_attachment" "ebs_att_conf" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.conf-jira_volume.id}"
  instance_id = "${aws_instance.confluence.id}"
}

resource "aws_volume_attachment" "ebs_att_jira" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.conf-jira_volume.id}"
  instance_id = "${aws_instance.jira.id}"
}

resource "aws_ebs_volume" "conf-jira_volume" {
  availability_zone = "asia-northeast-2a"
  size = 20 # giabyte
}
```