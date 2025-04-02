
provider "aws" {
  region = "eu-north-1"

}
resource "aws_vpc" "Ayush" {
  cidr_block       = "10.0.0.0/16"
  tags = {
  Name = "Ayush"
  }
}
resource "aws_subnet" "main" {
  vpc_id = aws_vpc.Ayush.id
  map_public_ip_on_launch = true
  cidr_block     = "10.0.0.0/24"
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Ayush.id

  tags = {
    Name = "my-igw"
  }
}
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.Ayush.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "a" {
   subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
}
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.Ayush.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Sg-group"
  }
}
resource "aws_instance" "this" {
  ami                     = "ami-0c2e61fdcb5495691"
  instance_type           = "t3.micro"
  subnet_id     = aws_subnet.main.id
  security_groups = [aws_security_group.sg.id]
  tags = {
    Name = "Test"
  }
}
