
resource "aws_security_group" "builders" {
  name        = "jenkins-builder"
  description = "Jenkins agent inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Temporary for debugging"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/8"]
  }

  ingress {
    description      = "Unsure whether anything else than port 22 is required from the Jenkins master.  Putting this here just in case"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/8"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({
    Name = "jenkins-builder"
  }, var.tags)
}
