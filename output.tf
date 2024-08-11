output "compartment_id" {
  value = var.compartment_id
}

output "instance_image_id" {
  value = var.amper_image_id
}

output "display_name_prefix" {
  value = var.display_name_prefix
}


output "public_vcn_id" {
  value = var.vcn_id
}
output "public_subnet_id" {
  value = var.public_subnet_id
}
output "private_subnet_id" {
  value = var.private_subnet_id
}

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
