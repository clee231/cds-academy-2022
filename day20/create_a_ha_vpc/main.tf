# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "ExamVPC"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.20.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.20.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private1"
  }
}


resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.20.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private2"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "main_ig_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "LabIGW"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_ig_gateway.id
  }

  tags = {
    Name = "PubRT"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "public_rt_subnet1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_subnet2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_subnet1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_vpc.main_vpc.main_route_table_id
}

resource "aws_route_table_association" "private_rt_subnet2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_vpc.main_vpc.main_route_table_id
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "public_sg" {
  name        = "PublicSG"
  description = "pubsg"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = "PrivateSG"
  description = "privsg"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket
data "aws_s3_bucket" "bucket" {
  bucket = "cfst-3377-c71659c918fb498d0f8c1ba46f266a-s3bucket-1mim416j70lvh"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log
resource "aws_flow_log" "ip_traffic" {
  log_destination      = data.aws_s3_bucket.bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main_vpc.id
}

