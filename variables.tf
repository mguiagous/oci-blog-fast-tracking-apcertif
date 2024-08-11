#. Provider              
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}


variable "oci_regions" {
  type = map(string)
  default = {
    "us-phoenix-1" = "PHX"
    "us-ashburn-1" = "IAD"
    # Add more regions as needed
  }
}


# Compartment
variable "compartment_id" {}

# Server Linux Image ID
variable "amper_image_id" {}

variable "display_name_prefix" {}

# Network (Step 1)
variable "create_vcn" {}

# Step 1(a) - You create the VCN wuing OCI Console)
variable "vcn_id" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}

# Step 1(b) - Terraform Create the VCN for you)
variable "vcn_cidr_block" {}
variable "public_subnet_cidr_block" {}
variable "private_subnet_cidr_block" {}
variable "host_name_prefix" {}

# Step 2 - Create 2 Network Security Groups)
variable "create_nsg_1" {}
variable "create_nsg_2" {}


# Step 3 VMs Creation
# (Step 3(a)) - Create 3 VMs in the public submet
variable "create_vm_1_3" {}
# (Step 3(b)) - Create 1 VM in the private submet
variable "create_vm_4" {}


# SSH Keys
variable "ssh_public_key" {}
variable "ssh_private_key" {}

# Shape Defintion
variable shape_name { 
   default = "VM.Standard.A1.Flex"
 }
  
variable shape_memory_in_gbs {
   default = "6"
}
variable shape_numberof_ocpus {
     default = "1"
}

# Step 4: Additional Automation - Add Ingress Rules to NSG-01 and attach it to VM-03 vNIC
variable "automate_step_4" {}

# Step 5: ICMP Tests from local computer
variable "icmp_pingvm1_fromlocal" {}
variable "icmp_pingvm2_fromlocal" {}
variable "icmp_pingvm3_fromlocal" {}

# Step 6: Additional Automation - Add Ingress Rules to NSG-02 and attach it to VM-04 vNIC
variable "automate_step_6" {}

# Step 7 - Run ICMP Echo Ping Tests from each of the 3 VMs in the public subnet
variable "icmp_test_from_vm1" {}
variable "icmp_test_from_vm2" {}
variable "icmp_test_from_vm3" {}
variable "icmp_ping_count" {}

