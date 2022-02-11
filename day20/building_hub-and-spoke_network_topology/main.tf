# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
data "aws_vpc" "vpc1" {
  tags = {
    Name = "VPC1"
  }
}

data "aws_vpc" "vpc2" {
  tags = {
    Name = "VPC2"
  }
}

data "aws_vpc" "vpc3" {
  tags = {
    Name = "VPC3"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway
resource "aws_ec2_transit_gateway" "main_tg" {
  description = "labtransitgw"
  tags = {
    Name = "labtransitgw"
  }
  amazon_side_asn = 65065
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet
data "aws_subnet" "public_subnet1" {
  filter {
    name   = "tag:Name"
    values = ["PublicSubnet1"]
  }
}

data "aws_subnet" "public_subnet2" {
  filter {
    name   = "tag:Name"
    values = ["PublicSubnet2"]
  }
}

data "aws_subnet" "public_subnet3" {
  filter {
    name   = "tag:Name"
    values = ["PublicSubnet3"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1" {
  subnet_ids         = [data.aws_subnet.public_subnet1.id]
  transit_gateway_id = aws_ec2_transit_gateway.main_tg.id
  vpc_id             = data.aws_vpc.vpc1.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2" {
  subnet_ids         = [data.aws_subnet.public_subnet2.id]
  transit_gateway_id = aws_ec2_transit_gateway.main_tg.id
  vpc_id             = data.aws_vpc.vpc2.id
}

# TO BE deleted later in Troubleshooting sections
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc3" {
  subnet_ids         = [data.aws_subnet.public_subnet3.id]
  transit_gateway_id = aws_ec2_transit_gateway.main_tg.id
  vpc_id             = data.aws_vpc.vpc3.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table
data "aws_route_table" "public1_rt" {
  tags = {
    Name = "Public1-RT"
  }
}

data "aws_route_table" "public2_rt" {
  tags = {
    Name = "Public2-RT"
  }
}

data "aws_route_table" "public3_rt" {
  tags = {
    Name = "Public3-RT"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
resource "aws_route" "public1_rt_tg_route_to_vpc2" {
  route_table_id         = data.aws_route_table.public1_rt.id
  destination_cidr_block = "10.2.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main_tg.id
}

resource "aws_route" "public1_rt_tg_route_to_vpc3" {
  route_table_id         = data.aws_route_table.public1_rt.id
  destination_cidr_block = "10.3.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main_tg.id
}

resource "aws_route" "public2_rt_tg_route_to_vpc1" {
  route_table_id         = data.aws_route_table.public2_rt.id
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main_tg.id
}

resource "aws_route" "public2_rt_tg_route_to_vpc3" {
  route_table_id         = data.aws_route_table.public2_rt.id
  destination_cidr_block = "10.3.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main_tg.id
}

resource "aws_route" "public3_rt_tg_route_to_vpc1" {
  route_table_id         = data.aws_route_table.public3_rt.id
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main_tg.id
}

resource "aws_route" "public3_rt_tg_route_to_vpc2" {
  route_table_id         = data.aws_route_table.public3_rt.id
  destination_cidr_block = "10.2.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main_tg.id
}


## Private Subnet NACL Modifications - Troubleshooting
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_acls
#data "aws_network_acls" "private1_nacl" {
#  tags = {
#    Name = "Private1-NACL"
#  }
#}
#
#data "aws_network_acls" "private2_nacl" {
#  tags = {
#    Name = "Private2-NACL"
#  }
#}
#
#data "aws_network_acls" "private3_nacl" {
#  tags = {
#    Name = "Private3-NACL"
#  }
#}
#
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
#resource "aws_network_acl_rule" "private3_nacl_rule_tcp" {
#  network_acl_id = data.aws_network_acls.private3_nacl.id
#  rule_number    = 100
#  egress         = false
#  protocol       = "tcp"
#  rule_action    = "allow"
#  cidr_block     = "0.0.0.0/0"
#  from_port      = 0
#  to_port        = 0
#}
#
#resource "aws_network_acl_rule" "private3_nacl_rule_icmp" {
#  network_acl_id = data.aws_network_acls.private3_nacl.id
#  rule_number    = 110
#  egress         = false
#  protocol       = "icmp"
#  rule_action    = "allow"
#  cidr_block     = "0.0.0.0/0"
#  from_port      = 0
#  to_port        = 0
#}
#
#resource "aws_network_acl_rule" "private3_nacl_rule_out_tcp" {
#  network_acl_id = data.aws_network_acls.private3_nacl.id
#  rule_number    = 100
#  egress         = true
#  protocol       = "tcp"
#  rule_action    = "allow"
#  cidr_block     = "0.0.0.0/0"
#  from_port      = 0
#  to_port        = 0
#}
#
#resource "aws_network_acl_rule" "private3_nacl_rule_out_icmp" {
#  network_acl_id = data.aws_network_acls.private3_nacl.id
#  rule_number    = 110
#  egress         = true
#  protocol       = "icmp"
#  rule_action    = "allow"
#  cidr_block     = "0.0.0.0/0"
#  from_port      = 0
#  to_port        = 0
#}
#
#
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet
#data "aws_subnet" "private_subnet1" {
#  filter {
#    name   = "tag:Name"
#    values = ["PrivateSubnet1"]
#  }
#}
#
#data "aws_subnet" "private_subnet2" {
#  filter {
#    name   = "tag:Name"
#    values = ["PrivateSubnet2"]
#  }
#}
#
#data "aws_subnet" "private_subnet3" {
#  filter {
#    name   = "tag:Name"
#    values = ["PrivateSubnet3"]
#  }
#}
#
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment
#resource "aws_ec2_transit_gateway_vpc_attachment" "vpc3_2" {
#  subnet_ids         = [data.aws_subnet.private_subnet3.id]
#  transit_gateway_id = aws_ec2_transit_gateway.main_tg.id
#  vpc_id             = data.aws_vpc.vpc3.id
#}
#
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table
#data "aws_route_table" "private1_rt" {
#  tags = {
#    Name = "Private1-RT"
#  }
#}
#
#data "aws_route_table" "private2_rt" {
#  tags = {
#    Name = "Private2-RT"
#  }
#}
#
#data "aws_route_table" "private3_rt" {
#  tags = {
#    Name = "Private3-RT"
#  }
#}
#
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
#resource "aws_route" "private3_rt_tg_route_to_vpc1" {
#  route_table_id         = data.aws_route_table.private3_rt.id
#  destination_cidr_block = "10.1.0.0/16"
#  transit_gateway_id     = aws_ec2_transit_gateway.main_tg.id
#}
#
#resource "aws_route" "private3_rt_tg_route_to_vpc2" {
#  route_table_id         = data.aws_route_table.private3_rt.id
#  destination_cidr_block = "10.2.0.0/16"
#  transit_gateway_id     = aws_ec2_transit_gateway.main_tg.id
#}
#
