## Introduction

This guide complements the OCI blog tutorial "**Fast-Tracking OCI Architect Pro Certification with Terraform**" by providing step-by-step instructions for setting up your Terraform environment to execute the OCI Professional Certification Lab-04.

In the future, we'll streamline the setup process by providing pre-configured images allowing you to concentrate on mastering OCI Architect Professional concepts and efficiently managing your lab resources.


## Prerequisites

Before you begin, ensure you have the following prerequisites met:

  * **Terraform v1.0.0 or greater**: Download and install it from the official website: <https://www.terraform.io/downloads.html/>
  * **Information from your OCI account** (free accounts are not valid for the lab):
    - Tenancy OCID: How to get [Tenancy OCID](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/contactingsupport_topic-Locating_Oracle_Cloud_Infrastructure_IDs.htm#Finding_Your_Tenancy_OCID_Oracle_Cloud_Identifier)
    - User OCID - How to get [User OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five)
    - Deployment Region - Find region identifiers in the following resources: 
      - Commercial Regions [Public Cloud](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm#About) 
      - Government Regions [US Gov](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/govfedramp.htm#Regions) or [US Defense](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/govfeddod.htm#Regions)
    - Create an API Key with the OCI Console: 
      - [Instruction to create an API Key then upload it to OCI Console](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#apisigningkey_topic_How_to_Generate_an_API_Signing_Key_Console)
      - [Uploading the Public Key](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#three)
      - Save the created API key as well as the fingerprint:
          1. Path Private Key File (~/.oci/oci_api_key.pem)
          2. API Fingerprint (d8:73:0b:............:d4:36)
    - SSH Keys to access Compute Instances:
      - [How to create ssh keys](https://docs.oracle.com/en/learn/generate_ssh_keys/index.html#introduction)
      - Make a note of the path where the generated SSH keys are located and add them to your terraform.tfvars configuration:
          1. Private Key Path (~/.ssh/mykey.key)
          2. Public Key Path (~/.ssh/mykey.pub)

## File Structure
When you unzip the lab04-demo.zip package into your working Terraform directory (e.g., terraform-ws), you'll have the following file structure:

terraform-ws/
├── lab04-demo/
│   ├── provider.auto.tfvars
│   ├── input.auto.tfvars (alias terraform.tfvars)
│   ├── network.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── output.tf
│   ├── provider.tf
│   ├── ping_script.sh
│   └── resources_clean_up.sh

### provider.auto.tfvars 
This file contains the configuration for the OCI Terraform provider, including authentication and connection details to OCI. Replace the string values within the `provider.auto.tfvars` with the values gathered from you tenancy.
```
tenancy       = "REPLACE_TENANCY_OCID_HERE" 
user_id       = "REPLACE_USER_OCID_HERE"
fingerprint   = "REPLACE_API_FINGERPRINT_OCID_HERE"
key_file_path = "REPLACE_PRIVATE_API_KEY_FILE_PATH_HERE"
region        = "REPLACE_REGION_IDENTIFIER_HERE"
```

## input.auto.tfvars (alias terraform.tfvars)
Modify the value of each variable listed below and provide your own entry before running terraform.

#### 1. Compartment 

How to get your [Compartment OCID](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/contactingsupport_topic-Locating_Oracle_Cloud_Infrastructure_IDs.htm#Finding_the_OCID_of_a_Compartment) 

Replace the string within `compartment_id` with the OCID of your working compartments (e.g.: OCIArchProCertif). 
```
compartment_id = "REPLACE_COMPARTMENT_OCID_HERE" 
```

### 2. VM image(s) 

How to find your VM image: https://docs.oracle.com/en-us/iaas/images/

First determine the OCID of the compute image that will be used to create Compute Instances - You can also use the image of one of previous VMs created manually from the OCI console or search for an Oracle supported Image OCID based on the region identifier using OCI CLI.

Replace by the determined linux image (the lab recommend to use the amper images). When creating a compute Instance in a different region you will have to change the value of the OCID to match the image of the target region.
  
```    
amper_image_id = "REPLACE_REGIONAL_IMAGE_OCID_HERE"
```

### 3. Display Name Prefix
All resource display names start with the Region abreviation ("PHX" for Phoenix or "IAD" for Ashburn) followed by "AP-LABX-Y". AP stand for `Architecture Professional`, X represent the `lab number` (01 for Lab 1) and Y represent the `lab sequence` (1 for 1st attempt, 2 for second attempt). 

The first network security group created for Lab 1 in Phoenix will have the following display name: *PHX-AP-LAB01-1-NSG-01*.  
 The index 1 in LAB01-1 represents the number of trial (1st trial) and the 01 after NSG indicates the first Network Security Group.
 The second Network Security Group of the third trial will have the following display name: *PHX-AP-LAB01-3-NSG-02*.
```
display_name_prefix = "AP-LAB01-1"
```
**Note:** The `oci_regions` map variable (see `variables.tf` below) is used to compute the 3 letters representing each OCI region (`IAD` for Ashburn, `PHX` for Phoenix, etc.). The region abbreviation is computed from that map variable. However you need to populate the map by adding your OCI regions identifiers and mapped abbreviations.

### 4. Virtual Cloud Network (VCN) 
There are two options to create the lab Virtual Cloud Network (VCN) to be used as the main resources under which all other resources will be created (VM, Subnets, NSG, etc.): 
- From the console use VCN Wizard to create the VCN stack 
- Using Terraform to create the VCN Stack from the scratch. 

#### 4.1. Create VCN with OCI VCN Wizard 

#### Step 1a
For this make sure to turn the `create_vcn` flag off, and copy from the console the following data (VCN OCIDs, Public subnets OCIDs, and Private Subnet OCIDs).

```   
create_vcn = false
vcn_id            = "REPLACE_NEW_VCN_OCID_HERE"
private_subnet_id = "REPLACE_PRIVATE_SUBNET_OCID_HERE"
public_subnet_id  = "REPLACE_PUBLIC_SUBNET_OCID_HERE"
```        

#### 4.2. Create VCN with Terraform
In case you want to let terraform create the VCN make sure to update the following: 
- set `create_vcn` flag to `true`
- provide the value of parameters needed to create your VCN:
  - VCN CIDR Block, 
  - Public Subnet CIDR Block, 
  - Private Subnet CIDR Block, 
  - Host name prefix

#### Step 1b
Provide the VCN & Subnet CIDR Blocks as well as host name prefix to be used
  
``` 
create_vcn = true

vcn_cidr_block            = "10.0.0.0/16"
public_subnet_cidr_block  = "10.0.0.0/24"
private_subnet_cidr_block = "10.0.1.0/24"
host_name_prefix          = "phxapl4"
``` 

### 5. SSH keys 
Replace the ssh_keys with the Public and Private key paths pointing to the location of the generated SSH Keys.
```
ssh_public_key  = "REPLACE_BY_SSH_PUBLIC_KEY_HERE"
ssh_private_key = "REPLACE_BY_SSH_PRIVATE_KEY_HERE"
```

### 6. Manual Execution vs Automation 
The variables below are boolean flags used to chose when the OCI resources creation or the testing activities are done manually (default value is `false`) or automated using Terraform (`true`). 

#### Create 2 Empty Network Security Groups (NSG-1 and NSG-2).                
```
create_nsg_1 = false
create_nsg_2 = false
```

#### Step 3: Create three VMs (_VM-01, _VM-02 and _VM-03) in public subnet 
```
create_vm_1_3 = false
```

#### Step 3: (b) Create a 4th VM (_VM-04) in the public subnet        
```
create_vm_4 = false
```

#### Step 4: Add CIDR Ingress Rule and associate VM3 vNIC with NSG-01
```
automate_step_4 = false
```

#### Step 5: Ping all the 3 public VMs From Local Computer
```
icmp_pingvm1_fromlocal = false
icmp_pingvm2_fromlocal = false
icmp_pingvm3_fromlocal = false
```
#### Step 6: Add NSG1 Ingress Rule and associate VM4 vNIC with NSG-02
```
automate_step_6 = false
```

#### Step 7: Ping VM-04 remotely from public VMs (VM01, VM02, VM03)
```
icmp_test_from_vm1 = false
icmp_test_from_vm2 = false
icmp_test_from_vm3 = false
```

### 7. Number of time ping is executed
This represents the number of time the ICMP Echo Ping will be executed (e.g., 3 or 5 pings) for basic testing purposes.

```
icmp_ping_count = "REPLACE_NUMBER_OF_PING_HERE"
```

## network.tf
This code creates all networking resources including but not limited to: VCN, Internet Gateway, Route Tables, Network Security Groups and Security Lists, Public Subnets and Private Subnets.

## main.tf
This is the main Terraform configuration file that specify the primary resource's definitions specially for the lab 4 - it launches three (3) VMs in public subnet and one (1) VM in the private subnet. It also orchestrates the access testing using provisioners to locally or remotely execute the ICMP Echo ping tests. This can be modified by a more sophisticated tool like ansible or shell scripts (see ping_scripts.sh).

## variables.tf
This file defines the input variables of the Terraform configurations witch values are specified in the `terraform.tfvars` file. It provides a way to parameterize the Terraform scripts. The majority of the parameters will be set as a single strings, boolean or number that used to create resources on OCI.

A map variable that represents OCI regions is used to define Display Names prefix. Make sure to update this map with full list of OCI regions identifiers mapped to the 3 letters abreviation for each region.

**Note:** If you want to use Oracle Ressource Manager (ORM) you need to edit the `variables.tf` and provide default values to be considered.

## outputs.tf
This file defines the output values of the Terraform configuration, which are useful for providing information about the created resources.

## ping_script.sh
This is an utility shell script to run ping commands inside a loop based on the value of the number_of_ping provided.

## resources_clean_up.sh
This second utility script allow to destroy all resources created during previous lab runs. This allows to free the OCI compute resources.

# Deployment tips

* For the display name if you do not provide a region prefix a default `OCI` will be added at the beginning of the resource name. It means that the default prefix value is applied only if the oci_region variable is empty.

* Modify all variable values, at least for testing purposes. Changes can be made once everything is working and you want to change associations 
  
* At this stage we are only using Terraform Community version and Oracle equivalent of Terraform Enterprise for remote state management, especially in a collaborative environment (a.k.a: Oracle Resource Manager)

* Check all changes are accurate before running the following terraform commands:
  
# Running the code
  ## Run init
  ```
  $ terraform init
  ```
  ## Create lab resources
  ```
  $ terraform apply
  ```
  ## Destroy lab resources
  ```
  $ terraform destroy
  ```

## Contributing
We welcome any feedback and contributions from the readers to improve and expand this guide. Whether it's fixing typos or adding clarity, or suggesting future extensions, your contributions are not only welcomed but highly valued.
