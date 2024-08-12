## This Network configuration was inferred from an ORM generated code by terraform-provider-oci

# Core VCN
resource "oci_core_vcn" "this" {
  count = (var.create_vcn) ? 1 : 0

  compartment_id = var.compartment_id
  cidr_block     = var.vcn_cidr_block
  #display_name   = "${var.display_name_prefix}-TF-VCN-01"
  display_name = "${try(var.oci_regions[var.region], "OCI")}-${var.display_name_prefix}-TF-VCN-01"
  dns_label      = "${var.host_name_prefix}core"
}


# Internet Gateway
resource "oci_core_internet_gateway" "this" {
  count = (var.create_vcn) ? 1 : 0

  compartment_id = var.compartment_id
  #display_name   = "${var.display_name_prefix}-TF-IGW-01"
    display_name = "${try(var.oci_regions[var.region], "OCI")}-${var.display_name_prefix}-TF-IGW-01"
  enabled        = "true"
  vcn_id         = oci_core_vcn.this.*.id[0]
}


# Default Routing Table
resource "oci_core_default_route_table" "this" {
  count = (var.create_vcn) ? 1 : 0

  compartment_id             = var.compartment_id
  #display_name               = "${var.display_name_prefix}-TF-RoutingTable"
     display_name = "${try(var.oci_regions[var.region], "OCI")}-${var.display_name_prefix}-TF-RoutingTable"
 
  manage_default_resource_id = oci_core_vcn.this.*.default_route_table_id[0]
  route_rules {
    description       = "Route Table for ${var.display_name_prefix}"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.*.id[0]
  }
}


resource "oci_core_network_security_group" "nsg-1" {
  count = (var.create_vcn && var.create_nsg_1) ? 1 : 0

  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.create_vcn ? oci_core_vcn.this.*.id[0] : var.vcn_id
  display_name = "${try(var.oci_regions[var.region], "OCI")}-${var.display_name_prefix}-TF-NSG-1"
  freeform_tags  = { "Lab" = "04" }
}


resource "oci_core_network_security_group" "nsg-01" {
  count = (!var.create_vcn && var.create_nsg_1) ? 1 : 0

  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name = "${try(var.oci_regions[var.region], "OCI")}-${var.display_name_prefix}-NSG-01"
  freeform_tags  = { "Lab" = "04" }
}


resource "oci_core_network_security_group" "nsg-2" {
  count = (var.create_vcn && var.create_nsg_2) ? 1 : 0

  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.create_vcn ? oci_core_vcn.this.*.id[0] : var.vcn_id
  display_name = "${try(var.oci_regions[var.region], "OCI")}-${var.display_name_prefix}-TF-NSG-2"
  freeform_tags  = { "Lab" = "04" }
}


resource "oci_core_network_security_group" "nsg-02" {
  count = (!var.create_vcn && var.create_nsg_2) ? 1 : 0

  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name = "${try(var.oci_regions[var.region], "OCI")}-${var.display_name_prefix}-NSG-02"
  freeform_tags  = { "Lab" = "04" }
}


# Network Security Group Rule for NSG-1 or NSG-01 
resource "oci_core_network_security_group_security_rule" "nsg-rule-1" {
  count       = (var.create_nsg_1 && var.automate_step_4) ? 1 : 0
  description = "Allow ICMP Echo Request (ping) from internet"
  direction   = "INGRESS"

  # Reference the Network Security Group where this rule applies
  #network_security_group_id = oci_core_network_security_group.nsg-1.*.id[0]
  network_security_group_id = var.create_vcn ? oci_core_network_security_group.nsg-1.*.id[0] :  oci_core_network_security_group.nsg-01.*.id[0]

  # ICMP protocol
  protocol = "1"

  # Destination is all (0.0.0.0/0 for IPv4)
  destination = ""
  source_type = "CIDR_BLOCK"

  # Source is the internet (0.0.0.0/0)
  source = "0.0.0.0/0"

  # ICMP options for type 8 (Echo Request)
  icmp_options {
    type = 8
    code = 0
  }

  # Optional: Allow stateful connections (recommended for ICMP)
  stateless = false

}


# Network Security Group Rule for NSG-01
resource "oci_core_network_security_group_security_rule" "nsg-2-rule" {
  count       = (var.create_nsg_2 && var.automate_step_4) ? 1 : 0
  description = "Allow ICMP Echo Request (ping) from internet"
  direction   = "INGRESS"

  # Reference the Network Security Group where this rule applies
  network_security_group_id = var.create_vcn ? oci_core_network_security_group.nsg-2.*.id[0] :  oci_core_network_security_group.nsg-02.*.id[0]


  # ICMP protocol
  protocol = "1"

  # Destination is all (0.0.0.0/0 for IPv4)
  destination = ""

  source_type = "NETWORK_SECURITY_GROUP"
  # Source is the internet (0.0.0.0/0)

  source = var.create_vcn ? oci_core_network_security_group.nsg-1.*.id[0] :  oci_core_network_security_group.nsg-01.*.id[0]

  # ICMP options for type 8 (Echo Request)
  icmp_options {
    type = 8
    code = 0
  }

  # Optional: Allow stateful connections (recommended for ICMP)
  stateless = false

}


# Default DHCP Options 
resource "oci_core_default_dhcp_options" "Default-DHCP-Options" {
  count = (var.create_vcn) ? 1 : 0

  compartment_id             = var.compartment_id
  display_name               = "${var.display_name_prefix}-TF-Default-DHCP-Options"
  domain_name_type           = "CUSTOM_DOMAIN"
  manage_default_resource_id = oci_core_vcn.this.*.default_dhcp_options_id[0]
  options {
    custom_dns_servers = []
    server_type        = "VcnLocalPlusInternet"
    type               = "DomainNameServer"
  }
  options {
    search_domain_names = [
      "${var.host_name_prefix}core.oraclevcn.com"
    ]
    type = "SearchDomain"
  }
}


# Private Subnet Route Table
resource "oci_core_route_table" "Route-Table-for-My-Private-Subnet" {
  count = (var.create_vcn) ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-TF-Route-Table-for-Private-Subnet"
  vcn_id         = oci_core_vcn.this.*.id[0]
}

# Regional Private Subnet
resource "oci_core_subnet" "My-Private-Subnet" {
  count = (var.create_vcn) ? 1 : 0

  #availability_domain = <<Optional value not found in discovery>>
  cidr_block                 = var.private_subnet_cidr_block
  compartment_id             = var.compartment_id
  dhcp_options_id            = oci_core_vcn.this.*.default_dhcp_options_id[0]
  display_name               = "${var.display_name_prefix}-TF-Private-Subnet"
  dns_label                  = "${var.host_name_prefix}prvnet"
  ipv6cidr_blocks            = []
  prohibit_internet_ingress  = "true"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.Route-Table-for-My-Private-Subnet.*.id[0]
  security_list_ids = [
    oci_core_security_list.Security-List-for-My-Private-Subnet.*.id[0],
  ]
  vcn_id = oci_core_vcn.this.*.id[0]
}


# Private Subnet Security List
resource "oci_core_security_list" "Security-List-for-My-Private-Subnet" {
  count = (var.create_vcn) ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-TF-Security-List-for-Private-Subnet"
  egress_security_rules {
    #description = <<Optional value not found in discovery>>
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    #icmp_options = <<Optional value not found in discovery>>
    protocol  = "all"
    stateless = "false"
    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }
  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }
  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol    = "6"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
      #source_port_range = <<Optional value not found in discovery>>
    }
    #udp_options = <<Optional value not found in discovery>>
  }
  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }
  vcn_id = oci_core_vcn.this.*.id[0]
}


# Default Security List 
resource "oci_core_default_security_list" "My-Default-Security-List" {
  count = (var.create_vcn) ? 1 : 0

  compartment_id = var.compartment_id

  display_name = "${var.display_name_prefix}-TF-Default-Security-List"

  egress_security_rules {
    description      = "Egress Open to all protocols"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    #icmp_options = <<Optional value not found in discovery>>
    protocol  = "all"
    stateless = "false"
    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }
  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }
  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }
  /*ingress_security_rules {
    description = "Openning Default Web Aplication Port 80 <Generated by Terraform>"
    #icmp_options = <<Optional value not found in discovery>>
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "80"
      min = "80"
      #source_port_range = <<Optional value not found in discovery>>
    }
    #udp_options = <<Optional value not found in discovery>>
  }*/
  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    #icmp_options = <<Optional value not found in discovery>>
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
    #udp_options = <<Optional value not found in discovery>>
  }
  manage_default_resource_id = oci_core_vcn.this.*.default_security_list_id[0]
}


# Regional Public Subnet
resource "oci_core_subnet" "My-Public-Subnet" {
  count = (var.create_vcn) ? 1 : 0

  #availability_domain = <<Optional value not found in discovery>>
  cidr_block                 = var.public_subnet_cidr_block
  compartment_id             = var.compartment_id
  dhcp_options_id            = oci_core_vcn.this.*.default_dhcp_options_id[0]
  display_name               = "${var.display_name_prefix}-TF-Public-Subnet"
  dns_label                  = "${var.host_name_prefix}pubnet"
  ipv6cidr_blocks            = []
  prohibit_internet_ingress  = "false"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_vcn.this.*.default_route_table_id[0]
  security_list_ids = [
    oci_core_vcn.this.*.default_security_list_id[0],
  ]
  vcn_id = var.create_vcn ? oci_core_vcn.this.*.id[0] : var.vcn_id
}
