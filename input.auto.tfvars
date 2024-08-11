###################################################################################
# Terraform module: Nested NSGs for OCI - NSG-01 as Ingress source to NSG-02      #  
# OCI Architect Professional Certification - Hands-on Lab 1.                      #
#                                                                                 #
# Copyright (c) 2024 Oracle                 Author: Mahamat Hissein Guiagoussou   #
###################################################################################

# Working Compartment 
compartment_id = "ocid1.compartment.oc1..aaaaaaaa26avuyz4nakngq3gyvfi7sfxx2oa2rmi2gtshhjnimuqtin6dzwa"

# Image OCID - Link to find your image: https://docs.oracle.com/en-us/iaas/images/
amper_image_id = "ocid1.image.oc1.phx.aaaaaaaa5a4rfsqnzcvoo72s7fegisywwrlfzkeav7vxjysowb7hlcviqxyq"

# Region based display name prefix
display_name_prefix = "AP-LAB01-1" # If you want a different Prefix replace it here

####################################################################################
# Step 1a - Create VCN using OCI COnsoiole - VCN Wizard (turn the flag off), then  #      
#           copy from the console the VCN OCID and subnets OCIDs (public, Private).#
####################################################################################
create_vcn = false

vcn_id            = "ocid1.vcn.oc1.phx.amaaaaaawe6j4fqa5c3bqmuneml3mrc6i4kstqgqgtvehxzja5dxx6p3dp3a"
public_subnet_id  = "ocid1.subnet.oc1.phx.aaaaaaaa2iv5gjkfs4cwzlkov6n6zxu645h4zuq6wbv2uklj3xiz5nqmgwkq"
private_subnet_id = "ocid1.subnet.oc1.phx.aaaaaaaaxlirofdbkilebvdwyjlcmgwo6nvwc3q6djeloqhtc34d2mkempza"

####################################################################################
# Step 1b - Terraform will create the VCN,subnets and all other network components.#
####################################################################################
vcn_cidr_block            = "10.0.0.0/16"
public_subnet_cidr_block  = "10.0.0.0/24"
private_subnet_cidr_block = "10.0.1.0/24"
host_name_prefix          = "phxapl4"

####################################################################################
# Step 2: Create 2 Empty Network Security Groups (NSG-1 and NSG-2).                #
######################################################################@#############
create_nsg_1 = true
create_nsg_2 = true

####################################################################################
# Step 3: (a) Create three (3) VMs (_VM-01, _VM-02 and _VM-03) in public subnet.   #
####################################################################################
create_vm_1_3 = true

####################################################################################
# Step 3: (b) Create a 4th VM (_VM-04) in the private subnet.                       #
####################################################################################
create_vm_4 = true

# Shape Defintion
shape_name  = "VM.Standard.A1.Flex"
shape_memory_in_gbs = "6"
shape_numberof_ocpus = "1"

# ICMP Ping from Local Computer
icmp_pingvm1_fromlocal = false
icmp_pingvm2_fromlocal = false
icmp_pingvm3_fromlocal = false

# SSH keys https://docs.oracle.com/en/learn/generate_ssh_keys/index.html#introduction
ssh_public_key  = "~/cloudshellkey.pub"
ssh_private_key = "~/cloudshellkey"

# ICMP Ping of VM-04 from Each Public VM (VM-02, VM-02, and VM-03) via SSH
icmp_test_from_vm1 = false
icmp_test_from_vm2 = false
icmp_test_from_vm3 = false

####################################################################################
# Step 4: Execute 2 sub-steps from console (CIDR Ingress Rule & VM3 vNIC<->NSG-01. #
####################################################################################
automate_step_4 = false

####################################################################################
# Step 5: SSH to the 3 public VMs (VM-01, VM-02, VM-03) and ping VM-04 (Attempt 1) # 
####################################################################################

####################################################################################
# Step 6: Execute 2 sub-steps from console (NSG1 Ingress Rule & VM4 vNIC<->NSG-02).#
####################################################################################
automate_step_6 = false

####################################################################################
# Step 7: SSH to the 3 public VMs (VM-01, VM-02, VM-03) and ping VM-04 (Attempt 2) #
####################################################################################

# Number of time ping is executed
icmp_ping_count = 7 



/*




*/