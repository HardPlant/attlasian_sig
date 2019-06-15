provider "aws" {
  region     = "ap-northeast-2"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# 인스턴스

resource "aws_instance" "confluence" {
  ami           = "ami-022009946a024d269" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.medium"

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

  #  provisioner "file" {
  #    source = "download_confluence.sh",
  #    destination = "/tmp/script.sh"
  #  }
  # provisioner "remote-exec" {
  #   inline = [
  # #    "sudo swapoff -a",
  # #    "sudo dd if=/dev/z,ero of=/var/swapfile bs=1M count=1024",
  # #    "sudo mkswap /var/swapfile",
  # #    "sudo swapon /var/swapfile",
  # #    "sudo swapon -s",
  #      "sudo bash /tmp/script.sh"
  #   ]
  # }
}

resource "aws_instance" "jira" {
  ami           = "ami-04e00e2e438d95d0d" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.medium"

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

  #  provisioner "file" {
  #    source = "download_jira.sh",
  #    destination = "/tmp/script.sh"
  #  }
  #  provisioner "remote-exec" {
  #    inline = [
  #    "sudo swapoff -a",
  #    "sudo dd if=/dev/z,ero of=/var/swapfile bs=1M count=1024",
  #    "sudo mkswap /var/swapfile",
  #    "sudo swapon /var/swapfile",
  #    "sudo swapon -s",
  #      "sudo bash /tmp/script.sh"
  #    ]
  # }
}
