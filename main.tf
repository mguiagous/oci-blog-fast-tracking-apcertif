data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "oci_core_instance" "VM1-3" {
  count = (var.create_vm_1_3) ? 3 : 0

  availability_config {
    is_live_migration_preferred = "true"
    recovery_action             = "RESTORE_INSTANCE"
  }

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  create_vnic_details {
    assign_private_dns_record = "true"
    assign_public_ip          = "true"
    subnet_id                 = var.create_vcn ? oci_core_subnet.My-Public-Subnet.*.id[0] : var.public_subnet_id
    nsg_ids = (var.automate_step_4 && var.create_nsg_1) ? (var.create_vcn ? [oci_core_network_security_group.nsg-1.*.id[0]] : [oci_core_network_security_group.nsg-01.*.id[0]]) : [] 
  }
  display_name = "${try(var.oci_regions[var.region], "OCI")}-${var.display_name_prefix}-VM-0${count.index + 1}"
  instance_options {
    are_legacy_imds_endpoints_disabled = "false"
  }
  is_pv_encryption_in_transit_enabled = "true"
  metadata = {
    "ssh_authorized_keys" = "${file(var.ssh_public_key)}"
  }

  shape = var.shape_name
  shape_config {
    baseline_ocpu_utilization = "BASELINE_1_1"
    memory_in_gbs             = var.shape_memory_in_gbs 
    ocpus                     = var.shape_numberof_ocpus 
  }
  source_details {
    source_id   = var.amper_image_id
    source_type = "image"
  }

  lifecycle {
    ignore_changes = [create_vnic_details]
  }

}


resource "oci_core_instance" "vm-4" {
  count = (var.create_vm_4) ? 1 : 0

  availability_config {
    is_live_migration_preferred = "true"
    recovery_action             = "RESTORE_INSTANCE"
  }
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  compartment_id      = var.compartment_id

  create_vnic_details {
    assign_private_dns_record = "true"
    assign_public_ip          = "false"
    subnet_id                 = var.create_vcn ? oci_core_subnet.My-Private-Subnet.*.id[0] : var.private_subnet_id
    nsg_ids = (var.automate_step_6 && var.create_nsg_2) ? (var.create_vcn ? [oci_core_network_security_group.nsg-2.*.id[0]] : [oci_core_network_security_group.nsg-02.*.id[0]]) : []                                    
  }
  display_name = "${try(var.oci_regions[var.region], "OCI")}-${var.display_name_prefix}-VM-04"

  instance_options {
    are_legacy_imds_endpoints_disabled = "false"
  }
  is_pv_encryption_in_transit_enabled = "true"
  shape                               = "VM.Standard.A1.Flex"
  shape_config {
    baseline_ocpu_utilization = "BASELINE_1_1"
    memory_in_gbs             = "6"
    ocpus                     = "1"
  }
  source_details {
    source_id   = var.amper_image_id
    source_type = "image"
  }

  lifecycle {
    ignore_changes = [create_vnic_details]
  }
}


resource "null_resource" "icmp_ping_VM1_fromlocal" {
  depends_on = [oci_core_instance.VM1-3[0]]
  count      = (var.icmp_pingvm1_fromlocal) ? 1 : 0

  # Create inventory
  provisioner "local-exec" {
    command = "sh /Users/mguiagou/terraform-ws/lab4-demo/ping_script.sh"
    environment = {
      TARGET_IP  = oci_core_instance.VM1-3[0].public_ip
      PING_COUNT = var.icmp_ping_count
    }
  }
}


resource "null_resource" "icmp_ping_VM2_fromlocal" {
  depends_on = [oci_core_instance.VM1-3[1]]
  count      = (var.icmp_pingvm2_fromlocal) ? 1 : 0

  # Ping VM2 from local Computer
  provisioner "local-exec" {
    #command = "ping ${oci_core_instance.VM1-3[1].public_ip}"
    command = "ping -c ${var.icmp_ping_count} ${oci_core_instance.VM1-3[1].public_ip}"
  }
}


resource "null_resource" "icmp_ping_VM3_fromlocal" {
  depends_on = [oci_core_instance.VM1-3[2]]
  count      = (var.icmp_pingvm3_fromlocal) ? 1 : 0

  # Create inventory
  provisioner "local-exec" {

    command = "ping ${oci_core_instance.VM1-3[2].public_ip}"

    #command = "sh /Users/mguiagou/terraform-ws/lab4-demo/ping_script.sh"
    #environment = {
    #  TARGET_IP  = oci_core_instance.VM1-3[2].public_ip
    #  PING_COUNT = 1000 #var.icmp_ping_count
    #}
  }
}


resource "null_resource" "icmp_ping_vm4_from_vm1" {
  depends_on = [oci_core_instance.VM1-3[0]]
  count      = (var.icmp_test_from_vm1) ? 1 : 0

  connection {
    agent       = false
    timeout     = "30m"
    host        = oci_core_instance.VM1-3[0].public_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "echo \" PING PRIVATE IP ${oci_core_instance.vm-4[0].private_ip}\"",
      "echo",
      "cd /home/opc/",
      "chmod +x /home/opc/ping_script.sh",
      "export TARGET_IP=${oci_core_instance.vm-4[0].private_ip}",
      "export PING_COUNT=${var.icmp_ping_count}",
      "sh /home/opc/ping_script.sh",
    ]
  }
}


resource "null_resource" "icmptest_ping_vm4_from_vm2" {
  depends_on = [oci_core_instance.VM1-3[1]]
  count      = (var.icmp_test_from_vm2) ? 1 : 0

  connection {
    agent       = false
    timeout     = "30m"
    host        = oci_core_instance.VM1-3[1].public_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "echo ",
      "echo \"################################################\"",
      "echo \" PINGING PRIVATE IP ${oci_core_instance.vm-4[0].private_ip}.\"",
      "echo \"################################################\"",
      "echo",
      "echo",
      "cd /home/opc/",
      "wget https://objectstorage.us-phoenix-1.oraclecloud.com/p/llP7uJI9zu54xpS_DG6KoqdnIWA2LCDIQN1I_R07Imr90aZkWbQug4ctbN-t15fa/n/orasenatdpltintegration03/b/OCI-ProCertif/o/ping_script.sh",
      "chmod +x /home/opc/ping_script.sh",
      "export TARGET_IP=${oci_core_instance.vm-4[0].private_ip}",
      "export PING_COUNT=${var.icmp_ping_count}",
      "sh /home/opc/ping_script.sh",
      #"ping -c ${var.icmp_ping_count} ${oci_core_instance.vm-4[0].private_ip}"
    ]
  }
}



resource "null_resource" "icmptest_ping_vm4_from_vm3" {
  depends_on = [oci_core_instance.VM1-3[2]]

  count = (var.icmp_test_from_vm3) ? 1 : 0

  connection {
    agent       = false
    timeout     = "30m"
    host        = oci_core_instance.VM1-3[2].public_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "echo ",
      "echo \"###############################################\"",
      "echo \" PINGING PRIVATE IP ${oci_core_instance.vm-4[0].private_ip}.\"",
      "echo \"###############################################\"",
      "echo",
      "echo",
      "ping ${oci_core_instance.vm-4[0].private_ip}"
    ]
  }
}



resource "null_resource" "ping-scrip-file-copier" {
  depends_on = [oci_core_instance.VM1-3[0]]
  count      = (var.icmp_test_from_vm1) ? 1 : 0

  connection {
    agent       = false
    timeout     = "30m"
    host        = oci_core_instance.VM1-3[0].public_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }


  # nginx installation
  provisioner "file" {
    source      = "/Users/mguiagou/terraform-ws/lab4-demo/ping_script.sh"
    destination = "/home/opc/ping_script.sh"
  }

}


#"ping -c ${var.icmp_ping_count} ${oci_core_instance.vm-4[0].private_ip}"
