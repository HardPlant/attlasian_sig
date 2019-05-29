
# VPC
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Default Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
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
# 인스턴스

resource "aws_instance" "confluence" {
  ami           = "ami-08ab3f7e72215fe91" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.micro"
  tags = {
      Name = "confluence"
      AutoStop = "true"
  }
  connection {
    # The default username for our AMI
    user = "ec2-user"
    #user = "ubuntu" #for ubuntu

    # The connection will use the local SSH agent for authentication.
  }
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.default.id}"
  
  root_block_device {
      volume_size = 10
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.confluence.public_ip} > ip_address_confluence.txt"
  }
}

resource "aws_instance" "jira" {
  ami           = "ami-08ab3f7e72215fe91" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.micro"
  tags = {
      Name = "jira"
      AutoStop = "true"
  }
  connection {
    # The default username for our AMI
    user = "ec2-user"
    #user = "ubuntu" #for ubuntu

    # The connection will use the local SSH agent for authentication.
  }
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.default.id}"
  
  root_block_device = {
      volume_size = 10
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.confluence.public_ip} > ip_address_jira.txt"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}
