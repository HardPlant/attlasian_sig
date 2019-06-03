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



##### Provisioner

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