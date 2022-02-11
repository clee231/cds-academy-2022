# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main_vpc" {
  cidr_block = "172.16.0.0/16"
  tags = {
    Name = "VPC1"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "main_ig_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_ig"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public1"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private1"
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
    Name = "PublicRT"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route = []

  tags = {
    Name = "PrivateRT"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "public_rt_subnet" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_subnet" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.main_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "Public_NACL"
  }
}

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "172.16.1.0/24"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "Private_NACL"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association
resource "aws_network_acl_association" "public_nacl" {
  network_acl_id = aws_network_acl.public_nacl.id
  subnet_id      = aws_subnet.public_1.id
}

resource "aws_network_acl_association" "private_nacl" {
  network_acl_id = aws_network_acl.private_nacl.id
  subnet_id      = aws_subnet.private_1.id
}
