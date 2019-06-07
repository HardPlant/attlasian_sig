provider "aws" {
  region     = "ap-northeast-2"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# 도메인 이름을 설정한다.
#resource "aws_route53_zone" "main" {
#  name = "themirai.net"
#}

# 도메인을 발급받으면 있는 호스팅 존의 id를 입력한다.
resource "aws_route53_record" "jira-ns" {
  zone_id = "Z3CARDE27EO8Y3"
  name    = "jira.themirai.net"
  type    = "A"
  ttl     = "30"

  records = [
    "${aws_eip.jira.public_ip}",
  ]
}

resource "aws_route53_record" "confluence-ns" {
  zone_id = "Z3CARDE27EO8Y3"
  name    = "confluence.themirai.net"
  type    = "A"
  ttl     = "30"

  records = [
    "${aws_eip.confluence.public_ip}",
  ]
}

# Confluence, Jira 도메인 이름과 연동할 IP를 가져온다.
resource "aws_eip" "confluence" {
  instance = "${aws_instance.confluence.id}"
  vpc      = true
}

resource "aws_eip" "jira" {
  instance = "${aws_instance.jira.id}"
  vpc      = true
}

# Grant the VPC internet access on its main route table
# VPC : 가상 내부망을 하나 설정한다.
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

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

  # Jira
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Confluence
  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 인스턴스

resource "aws_instance" "confluence" {
  ami           = "ami-0d854956dd41273cf" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.small"

  tags = {
    Name     = "confluence"
    AutoStop = "true"
  }

  connection {
    # The default username for our AMI
    user = "ec2-user"

    #user = "ubuntu" #for ubuntu

    # The connection will use the local SSH agent for authentication.
  }

  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id              = "${aws_subnet.default.id}"

  root_block_device {
    volume_size = 10
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.confluence.public_ip} > ip_address_confluence.txt"
  }

  # provisioner "file" {
  #   source = "download_confluence.sh",
  #   destination = "/tmp/script.sh"
  # }
  provisioner "remote-exec" {
    inline = [
      "sudo swapoff -a",
      "sudo dd if=/dev/z,ero of=/var/swapfile bs=1M count=1024",
      "sudo mkswap /var/swapfile",
      "sudo swapon /var/swapfile",
      "sudo swapon -s",
    ]
  }
}

resource "aws_instance" "jira" {
  ami           = "ami-0b02efe469ac0d8b0" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.small"

  tags = {
    Name     = "jira"
    AutoStop = "true"
  }

  connection {
    # The default username for our AMI
    user = "ec2-user"

    #user = "ubuntu" #for ubuntu

    # The connection will use the local SSH agent for authentication.
  }

  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id              = "${aws_subnet.default.id}"

  root_block_device = {
    volume_size = 10
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.jira.public_ip} > ip_address_jira.txt"
  }

  # provisioner "file" {
  #   source = "download_jira.sh",
  #   destination = "/tmp/script.sh"
  # }
   provisioner "remote-exec" {
     inline = [
      "sudo swapoff -a",
      "sudo dd if=/dev/z,ero of=/var/swapfile bs=1M count=1024",
      "sudo mkswap /var/swapfile",
      "sudo swapon /var/swapfile",
      "sudo swapon -s",
  #     "chmod +x /tmp/script.sh",
  #     "/tmp/script.sh"
     ]
   }
}
