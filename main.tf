resource "aws_security_group" "jenkins-SG1" {
  name = "jenkins-SG1"
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
resource "aws_instance" "Jenkins-VM" {
    count = 3
  instance_type          = "t2.micro"
  ami                    = "ami-00e87074e52e6c9f9"
  vpc_security_group_ids = [aws_security_group.jenkins-SG1.id]
  key_name               = "jenkins-key"
  tags = {
    Name = "Jenkins-VM-${count.index}"
  }
}


output "jenkins_endpoint" {
  value = aws_instance.Jenkins-VM.*.public_ip
}