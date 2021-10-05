resource "aws_security_group" "JenkinsSG" {
  name = "Jenkins SG"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "terra" {
  instance_type          = "t2.micro"
  ami                    = "ami-0057d8e6fb0692b80"
  vpc_security_group_ids = [aws_security_group.JenkinsSG.id]
  key_name               = "jenkins-key"
  user_data              = <<-EOF
		    #!/bin/bash
        sudo yum install  wget -y
        sudo wget -O /etc/yum.repos.d/jenkins.repo \
        https://pkg.jenkins.io/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        sudo yum upgrade -y
        sudo yum install epel-release java-11-openjdk-devel -y
        sudo yum install jenkins -y
        sudo systemctl daemon-reload
        sudo systemctl restart jenkins
        sudo yum install java -y
        sudo yum install python3 -y
    EOF  

  tags = {
    Name = "terra"

  }

}

resource "aws_key_pair" "jenkins-key" {
  key_name   = "jenkins-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCv0tiM43phyROpXtg2uuiqb+gaxhl6PHT3tabnjT3KO+/Gj9dX0h3G+Cnc9zZWs2OIAU2sSeFCLiwnq5nKMA3XhplugEH299sl5z7uEbSb/yxM5inNUrfovFquvYyMiIra4oU8IR0EzqWYlQEkJ07nfZ0HrmNf1S1PWhobnOPZk4pBtiE9ZJlZRFTOVo/qNyoV63pFwACikOY4DGz+9NGJNC3wGnJ6Y0yZ8xj5sqLh9IAwVS66tOcIzMF1SLDPUl2phJEneAITKmqjTj2/wljsxKYPOO1ibAhtk+pBJSSBC09stl9j9JTJSumgDwTKydowluJ6EewY8qA4+ANKzKrf jenkins-key"
}

output "jenkins_endpoint1" {
  value = formatlist("http://%s:%s/", aws_instance.terra.*.public_ip, "8080")
}
