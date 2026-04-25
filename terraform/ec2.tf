data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ci_server_sg" {
  name        = "ci-server-sg"
  description = "Security group for CI server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
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

resource "tls_private_key" "ci_server_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ci_server_key_pair" {
  key_name   = "ci-server-key"
  public_key = tls_private_key.ci_server_key.public_key_openssh
}

resource "aws_instance" "ci_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = aws_key_pair.ci_server_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.ci_server_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Jenkins-CI-Server"
  }
}

resource "aws_eip" "ci_server_eip" {
  instance = aws_instance.ci_server.id
  domain   = "vpc"

  tags = {
    Name = "Jenkins-CI-Server-EIP"
  }
}
