variable "aws_key_pair" {
  default = "./demo_ec2_key.pem"
}


resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}


data "aws_subnet_ids" "default_subnets" {
  vpc_id = aws_default_vpc.default.id
}

data "aws_ami" "aws_linux_2_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

resource "aws_security_group" "ec2_server_sg_one" {
  name = "http_server_sg_one"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "ec2_server_sg"
  }
}

resource "aws_instance" "ec2_server" {
  ami                    = data.aws_ami.aws_linux_2_latest.id
  key_name               = "demo_ec2_key"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_server_sg_one.id]
  subnet_id = tolist(data.aws_subnet_ids.default_subnets.ids)[0]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo service httpd start",
      "echo My server dns: ${self.public_dns} | sudo tee /var/www/html/index.html"
    ]
  }
}


output "aws_security_group_ec2_server_details" {
  value = aws_security_group.http_server_sg
}

output "ec2_server_public_dns" {
  value = aws_instance.ec2_server.public_dns
}
