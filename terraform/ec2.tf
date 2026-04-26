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

resource "aws_security_group" "k8s_node_sg" {
  name        = "k8s-node-sg"
  description = "Security group for MicroK8s Node"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MicroK8s API"
    from_port   = 16443
    to_port     = 16443
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

resource "tls_private_key" "k8s_node_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k8s_node_key_pair" {
  key_name   = "k8s-node-key"
  public_key = tls_private_key.k8s_node_key.public_key_openssh
}

resource "aws_instance" "k8s_node" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = aws_key_pair.k8s_node_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.k8s_node_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name = "RoboShop-MicroK8s-Node"
  }
}

resource "aws_eip" "k8s_node_eip" {
  instance = aws_instance.k8s_node.id
  domain   = "vpc"

  tags = {
    Name = "RoboShop-MicroK8s-Node-EIP"
  }
}
