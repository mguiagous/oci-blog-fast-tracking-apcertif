#!/bin/bash

source /Users/mguiagou/terraform-ws/lab4-demo/env-vars 
/usr/local/bin/terraform init
/usr/local/bin/terraform destroy --auto-approve
/usr/local/bin/terraform destroy --auto-approve

