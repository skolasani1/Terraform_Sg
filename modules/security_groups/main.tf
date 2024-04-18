provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "Mysg" {
  name        = "Mysg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  # Dynamic block for ingress rules
  dynamic "ingress" {
    for_each = var.web_ingress
    content {
      description = "TLS from VPC"
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_block  # corrected from cidr_blocks to cidr_block
    }
  }

  # Egress rule
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Mysg"
  }
}

variable "web_ingress" {
  type = map(object({
    port       = number
    protocol   = string
    cidr_block = list(string)
  }))
  default = {
    "80" = {
      port       = 80
      protocol   = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },
    "443" = {
      port       = 443
      protocol   = "tcp"
      cidr_block = ["0.0.0.0/0"]
    }
  }
}
