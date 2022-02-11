# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group
data "aws_security_group" "bastion" {
  tags = {
    Name = "Bastion"
  }
}

data "aws_security_group" "appserver" {
  tags = {
    Name = "AppServer"
  }
}

data "aws_security_group" "rds" {
  tags = {
    Name = "RDSDB"
  }
}

data "aws_security_group" "alb" {
  tags = {
    Name = "ALB"
  }
}

# https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "bastion_my_ip" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = data.aws_security_group.bastion.id
}

resource "aws_security_group_rule" "alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.alb.id
}

resource "aws_security_group_rule" "appserver_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = data.aws_security_group.alb.id
  security_group_id = data.aws_security_group.appserver.id
}

resource "aws_security_group_rule" "appserver_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = data.aws_security_group.bastion.id
  security_group_id = data.aws_security_group.appserver.id
}

resource "aws_security_group_rule" "rdsdb_appserver" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = data.aws_security_group.appserver.id
  security_group_id = data.aws_security_group.rds.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
data "aws_vpc" "main" {
  tags = {
    Name = "SecurityEssentials"
  }
}

# https://regstry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_acls
data "aws_network_acls" "dmz" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Name = "DMZ"
  }
}

data "aws_network_acls" "applayer" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Name = "AppLayer"
  }
}

data "aws_network_acls" "dblayer" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Name = "DBLayer"
  }
}

# DMZ
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
resource "aws_network_acl_rule" "dmz_ssh" {
  network_acl_id = data.aws_network_acls.dmz.ids[0]
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "dmz_http" {
  network_acl_id = data.aws_network_acls.dmz.ids[0]
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "dmz_https" {
  network_acl_id = data.aws_network_acls.dmz.ids[0]
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "dmz_ephemeral" {
  network_acl_id = data.aws_network_acls.dmz.ids[0]
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "dmz_out_ssh" {
  network_acl_id = data.aws_network_acls.dmz.ids[0]
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "dmz_out_http" {
  network_acl_id = data.aws_network_acls.dmz.ids[0]
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "dmz_out_https" {
  network_acl_id = data.aws_network_acls.dmz.ids[0]
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "dmz_out_ephemeral" {
  network_acl_id = data.aws_network_acls.dmz.ids[0]
  rule_number    = 130
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet#filter
data "aws_subnets" "dmz_subnets" {
  filter {
    name   = "tag:Name"
    values = ["DMZ1public", "DMZ2public"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association
resource "aws_network_acl_association" "dmz_subnets" {
  network_acl_id = data.aws_network_acls.dmz.ids[0]
  for_each = toset(data.aws_subnets.dmz_subnets.ids)
  subnet_id      = each.key
}


## AppLayer
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule

resource "aws_network_acl_rule" "applayer_http" {
  network_acl_id = data.aws_network_acls.applayer.ids[0]
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "applayer_ephemeral" {
  network_acl_id = data.aws_network_acls.applayer.ids[0]
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "applayer_out_http" {
  network_acl_id = data.aws_network_acls.applayer.ids[0]
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "applayer_out_ephemeral" {
  network_acl_id = data.aws_network_acls.applayer.ids[0]
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet#filter
data "aws_subnets" "applayer_subnets" {
  filter {
    name   = "tag:Name"
    values = ["AppLayer1", "AppLayer2"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association
resource "aws_network_acl_association" "applayer_subnets" {
  network_acl_id = data.aws_network_acls.applayer.ids[0]
  for_each = toset(data.aws_subnets.applayer_subnets.ids)
  subnet_id      = each.key
}


## DBLayer
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule

resource "aws_network_acl_rule" "dblayer_sql" {
  network_acl_id = data.aws_network_acls.dblayer.ids[0]
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3306
  to_port        = 3306
}

resource "aws_network_acl_rule" "dblayer_ephemeral" {
  network_acl_id = data.aws_network_acls.dblayer.ids[0]
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "dblayer_out_sql" {
  network_acl_id = data.aws_network_acls.dblayer.ids[0]
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3306
  to_port        = 3306
}

resource "aws_network_acl_rule" "dblayer_out_ephemeral" {
  network_acl_id = data.aws_network_acls.dblayer.ids[0]
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet#filter
data "aws_subnets" "dblayer_subnets" {
  filter {
    name   = "tag:Name"
    values = ["DBLayer1", "DBLayer2"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association
resource "aws_network_acl_association" "dblayer_subnets" {
  network_acl_id = data.aws_network_acls.dblayer.ids[0]
  for_each = toset(data.aws_subnets.dblayer_subnets.ids)
  subnet_id      = each.key
}

