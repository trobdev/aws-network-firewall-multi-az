##---root/main.tf---

##---VPC---
resource "aws_vpc" "aws_inspection_vpc" {
  tags                                 = merge(var.tags, {})
  enable_network_address_usage_metrics = true
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  cidr_block                           = "172.16.0.0/24"
}

resource "aws_internet_gateway" "aws_internet_gateway" {
  vpc_id = aws_vpc.aws_inspection_vpc.id
  tags   = merge(var.tags, {})
}

resource "aws_eip" "eip_a" {
  domain = "vpc"
  public_ipv4_pool = "amazon"
}

resource "aws_eip" "eip_b" {
  domain = "vpc"
  public_ipv4_pool = "amazon"
}
##---NATGW SUBNET A---
resource "aws_subnet" "aws_subnet_natgw_a" {
  cidr_block = "172.16.0.0/28"
  vpc_id            = aws_vpc.aws_inspection_vpc.id
  tags              = merge(var.tags, {})
  availability_zone = "us-east-1a"
}
resource "aws_nat_gateway" "aws_nat_gateway_a" {
  allocation_id = aws_eip.eip_a.id
  tags      = merge(var.tags, {})
  subnet_id = aws_subnet.aws_subnet_natgw_a.id
}

resource "aws_route_table" "aws_route_table_natgw_a" {
  vpc_id = aws_vpc.aws_inspection_vpc.id
  tags   = merge(var.tags, {})

  route {
    network_interface_id = data.aws_network_interface.ENI_A.id
    cidr_block      = "192.168.0.0/16"
  }
  route {
    gateway_id = aws_internet_gateway.aws_internet_gateway.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "aws_route_table_association_natgw_a" {
  subnet_id      = aws_subnet.aws_subnet_natgw_a.id
  route_table_id = aws_route_table.aws_route_table_natgw_a.id
}
##---NATGW SUBNET B---
resource "aws_subnet" "aws_subnet_natgw_b" {
  cidr_block = "172.16.0.16/28"
  vpc_id            = aws_vpc.aws_inspection_vpc.id
  tags              = merge(var.tags, {})
  availability_zone = "us-east-1b"
}
resource "aws_nat_gateway" "aws_nat_gateway_b" {
  allocation_id = aws_eip.eip_b.id
  tags      = merge(var.tags, {})
  subnet_id = aws_subnet.aws_subnet_natgw_b.id
}

resource "aws_route_table" "aws_route_table_natgw_b" {
  vpc_id = aws_vpc.aws_inspection_vpc.id
  tags   = merge(var.tags, {})

  route {
    network_interface_id = data.aws_network_interface.ENI_B.id
    cidr_block      = "192.168.0.0/16"
  }
  route {
    gateway_id = aws_internet_gateway.aws_internet_gateway.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "aws_route_table_association_natgw_b" {
  subnet_id      = aws_subnet.aws_subnet_natgw_b.id
  route_table_id = aws_route_table.aws_route_table_natgw_b.id
}

##---APPLIANCE SUBNET A---
resource "aws_subnet" "aws_subnet_appliance_a" {
  cidr_block = "172.16.0.32/28"
  vpc_id            = aws_vpc.aws_inspection_vpc.id
  tags              = merge(var.tags, {})
  availability_zone = "us-east-1a"
}

resource "aws_route_table" "aws_route_table_appliance_a" {
  vpc_id = aws_vpc.aws_inspection_vpc.id
  tags   = merge(var.tags, {})

  route {
    transit_gateway_id = aws_ec2_transit_gateway.aws_ec2_transit_gateway.id
    cidr_block         = "192.168.0.0/16"
  }
  route {
    nat_gateway_id = aws_nat_gateway.aws_nat_gateway_a.id
    cidr_block     = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "aws_route_table_association_appliance_a" {
  subnet_id      = aws_subnet.aws_subnet_appliance_a.id
  route_table_id = aws_route_table.aws_route_table_appliance_a.id
}

##---APPLIANCE SUBNET B---
resource "aws_subnet" "aws_subnet_appliance_b" {
  cidr_block = "172.16.0.48/28"
  vpc_id            = aws_vpc.aws_inspection_vpc.id
  tags              = merge(var.tags, {})
  availability_zone = "us-east-1b"
}

resource "aws_route_table" "aws_route_table_appliance_b" {
  vpc_id = aws_vpc.aws_inspection_vpc.id
  tags   = merge(var.tags, {})

  route {
    transit_gateway_id = aws_ec2_transit_gateway.aws_ec2_transit_gateway.id
    cidr_block         = "192.168.0.0/16"
  }
  route {
    nat_gateway_id = aws_nat_gateway.aws_nat_gateway_b.id
    cidr_block     = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "aws_route_table_association_appliance_b" {
  subnet_id      = aws_subnet.aws_subnet_appliance_b.id
  route_table_id = aws_route_table.aws_route_table_appliance_b.id
}

##---TGW SUBNET A---
resource "aws_subnet" "aws_subnet_tgw_subnet_a" {
  cidr_block = "172.16.0.64/28"
  vpc_id            = aws_vpc.aws_inspection_vpc.id
  tags              = merge(var.tags, {})
  availability_zone = "us-east-1a"
}

resource "aws_route_table" "aws_route_table_tgw_subnet_a" {
  vpc_id = aws_vpc.aws_inspection_vpc.id
  tags   = merge(var.tags, {})

  route {
    network_interface_id = data.aws_network_interface.ENI_A.id
    cidr_block      = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "aws_route_table_association_tgw_a" {
  subnet_id      = aws_subnet.aws_subnet_tgw_subnet_a.id
  route_table_id = aws_route_table.aws_route_table_tgw_subnet_a.id
}

##---TGW SUBNET B---
resource "aws_subnet" "aws_subnet_tgw_subnet_b" {
  cidr_block = "172.16.0.80/28"
  vpc_id            = aws_vpc.aws_inspection_vpc.id
  tags              = merge(var.tags, {})
  availability_zone = "us-east-1b"
}

resource "aws_route_table" "aws_route_table_tgw_subnet_b" {
  vpc_id = aws_vpc.aws_inspection_vpc.id
  tags   = merge(var.tags, {})

  route {
    network_interface_id = data.aws_network_interface.ENI_B.id
    cidr_block      = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "aws_route_table_association_tgw_b" {
  subnet_id      = aws_subnet.aws_subnet_tgw_subnet_b.id
  route_table_id = aws_route_table.aws_route_table_tgw_subnet_b.id
}
##---NETWORK FIREWALL---
##VPCE for AWS Network Firewall is not available in console or API without filters, requires to be read after creation of AWS Network
##Firewall.  Must be obtained using the created filters for NFW (see below) and then read from the route table when creating the route. 
data "aws_vpc_endpoint" "firewall_a" {
  vpc_id = aws_vpc.aws_inspection_vpc.id
  state = "available"

  tags = {
    Firewall = aws_networkfirewall_firewall.aws_networkfirewall_firewall_a.arn
    AWSNetworkFirewallManaged = "true"
  }
}

data "aws_vpc_endpoint" "firewall_b" {
  vpc_id = aws_vpc.aws_inspection_vpc.id
  state = "available"

  tags = {
    Firewall = aws_networkfirewall_firewall.aws_networkfirewall_firewall_b.arn
    AWSNetworkFirewallManaged = "true"
  }
}
##Use local source to specify the interface ID of the VPCE as a string
locals {
  key_a = join(",", data.aws_vpc_endpoint.firewall_a.network_interface_ids)
  key_b = join(",", data.aws_vpc_endpoint.firewall_b.network_interface_ids)
}
##read data of the VPCEs and specifically the interface IDs
data "aws_network_interface" "ENI_A" {
  id = local.key_a
}

data "aws_network_interface" "ENI_B" {
  id = local.key_b
}
resource "aws_networkfirewall_firewall" "aws_networkfirewall_firewall_a" {
  vpc_id              = aws_vpc.aws_inspection_vpc.id
  tags                = merge(var.tags, {})
  name                = "firewalla"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.aws_networkfirewall_firewall_policy.arn

  subnet_mapping {
    subnet_id = aws_subnet.aws_subnet_appliance_a.id
  }

}

resource "aws_networkfirewall_firewall" "aws_networkfirewall_firewall_b" {
  vpc_id              = aws_vpc.aws_inspection_vpc.id
  tags                = merge(var.tags, {})
  name                = "firewallb"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.aws_networkfirewall_firewall_policy.arn

  subnet_mapping {
    subnet_id = aws_subnet.aws_subnet_appliance_b.id
  }

}

resource "aws_networkfirewall_firewall_policy" "aws_networkfirewall_firewall_policy" {
  tags = merge(var.tags, {})
  name = "policytest" #CANNOT HAVE ANY _ OR - INCLUDED
  firewall_policy {
    stateless_default_actions = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
  }
}

resource "aws_networkfirewall_rule_group" "aws_networkfirewall_rule_group" {
  name = "rulegrouptest" #CANNOT HAVE ANY _ OR - INCLUDED
  type = "STATEFUL"
  capacity = 100
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST"]
        targets              = ["test.example.com"]
      }
    }
  }
  tags = merge(var.tags, {})
}

##---TRANSIT GATEWAY DEVICE(HUB) AND ATTACHMENTS---
resource "aws_ec2_transit_gateway" "aws_ec2_transit_gateway" {
  tags = merge(var.tags, {})
}

resource "aws_ec2_transit_gateway_vpc_attachment" "aws_ec2_transit_gateway_vpc_attachment_inspection" {
  vpc_id                                          = aws_vpc.aws_inspection_vpc.id
  transit_gateway_id                              = aws_ec2_transit_gateway.aws_ec2_transit_gateway.id
  transit_gateway_default_route_table_propagation = false
  transit_gateway_default_route_table_association = false
  tags                                            = merge(var.tags, {})
  dns_support                                     = "enable"
  appliance_mode_support                          = "enable"

  subnet_ids = [
    aws_subnet.aws_subnet_tgw_subnet_a.id,
    aws_subnet.aws_subnet_tgw_subnet_b.id,
  ]
}

resource "aws_ec2_transit_gateway_route_table" "aws_ec2_transit_gateway_route_table_egress" {
  transit_gateway_id = aws_ec2_transit_gateway.aws_ec2_transit_gateway.id
  tags               = merge(var.tags, {})
}

resource "aws_ec2_transit_gateway_route" "tgw_route_to_attachment_inspection" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.aws_ec2_transit_gateway_route_table_egress.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.aws_ec2_transit_gateway_vpc_attachment_inspection.id
  destination_cidr_block         = "0.0.0.0/0"
  blackhole                      = false
}

resource "aws_ec2_transit_gateway_route_table_association" "aws_ec2_transit_gateway_route_table_association_egress" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.aws_ec2_transit_gateway_route_table_egress.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.aws_ec2_transit_gateway_vpc_attachment_inspection.id
}

# resource "aws_ec2_transit_gateway_route_table_propagation" "aws_ec2_transit_gateway_route_table_propagation_egress" {
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.aws_ec2_transit_gateway_route_table_egress.id
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.aws_ec2_transit_gateway_vpc_attachment_inspection.id
# }

resource "aws_ec2_transit_gateway_route_table" "aws_ec2_transit_gateway_route_transit" {
  transit_gateway_id = aws_ec2_transit_gateway.aws_ec2_transit_gateway.id
  tags               = merge(var.tags, {})
}

resource "aws_ec2_transit_gateway_route" "tgw_route_to_attachment_spokes" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.aws_ec2_transit_gateway_route_transit.id
  destination_cidr_block         = "192.168.0.0/16"
  blackhole                      = true
}



