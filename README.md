# Automated Way to Restore an EC2 Instance

## Overview
This script can be useful if you need to restore a specific EC2 instance through an automated process. <br />
This process will be split into three steps. <br />
<br />
The scripts can be executed on a terminal (putty) or AWS Cloudshell.

## 1. Collect the EC2 info
*Script: ec2_json_data_backup.sh*

- This step will save all necessary info from the selected instances, to be used during restore.
- It will create two or more JSON files.
  - One file: ec2_data_backup.txt. It contains the info from all selected EC2 instances just in case you want to save it on a Excel file.
  - One or more files: <instance_name>.txt: each file contains the info from each selected EC2 instance. Those files will be used during the AMI restore process.

When the script, you have to provide the **region** and **EC2 name** defined on Tag key: Name.

E.g. if you provide the word restored for the EC2 name, it will search all instances with that name.

## 2. Creating an AMI
*Script: ami_backup.sh*

- It will create one AMI for each selected instance.
- E.g. ami_<instance_name>.txt
- Those files will be used to restore the AMI if necessary.

## 3. AMI restore
*Script: ami_restore.sh*

- It will restore the AMI from a particular instance. 
- The AMI has to be created through the script **ami_backup.sh** mentioned on step2.
- Restore process: 
  - After executing the script, you have to provide the region and EC2 name defined on Tag key: Name.
  - **Note** You need to provide the exact name of the instance. You can check it on the files created by the script ec2_json_data_backup.sh.
