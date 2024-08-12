# Working Compartment OCID
output "compartment_id" {
  value = var.compartment_id
}

# Instance Image OCID
output "instance_image_id" {
  value = var.amper_image_id
}

# Display Name Prefix
output "display_name_prefix" {
  value = var.display_name_prefix
}

# VCN OCID
output "public_vcn_id" {
  value = var.vcn_id
}

# Public Subnet OCID
output "public_subnet_id" {
  value = var.public_subnet_id
}

# Private Subnet OCID
output "private_subnet_id" {
  value = var.private_subnet_id
}

# Public VM OCID, Display Name & Public IP
output "_vm1-3_id" {
  value = oci_core_instance.VM1-3.*.id
}
output "_vm1-3_name" {
  value = oci_core_instance.VM1-3.*.display_name
}
output "_vm1-3_public_ip" {
  value = oci_core_instance.VM1-3.*.public_ip
}
output "_vm1-3_private_ip" {
  value = oci_core_instance.VM1-3.*.private_ip
}


# Private VM OCID, Display Name & Public IP
output "_vm4_id" {
  value = oci_core_instance.vm-4.*.id
}
output "_vm4_name" {
  value = oci_core_instance.vm-4.*.display_name
}
output "_vm4_public_ip" {
  value = oci_core_instance.vm-4.*.public_ip
}
output "_vm4_private_ip" {
  value = oci_core_instance.vm-4.*.private_ip
}


# Network Security Groups OCID & Name 
output "_nsg1_id" {
  value = oci_core_network_security_group.nsg-01.*.id
}
output "_nsg2_id" {
  value = oci_core_network_security_group.nsg-02.*.id
}
output "_nsg1_name" {
  value = oci_core_network_security_group.nsg-01.*.display_name
}
output "_nsg2_name" {
  value = oci_core_network_security_group.nsg-02.*.display_name
}
