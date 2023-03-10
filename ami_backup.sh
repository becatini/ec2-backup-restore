#!/bin/bash  
#########################################
# Script to create AMI for C8 migration #
#########################################

begin_script () {
  date=`date +%m-%d-%Y`
  #region=us-east-1
  
  read -p "Enter region: " region
  read -p "Enter EC2 instances: " ec2
  echo " ";
  
  #Search the instances to create the AMI
  for instance_id in $(aws ec2 describe-instances --region $region --query 'Reservations[*].Instances[*].[InstanceId]' --filters "Name=tag:Name,Values='*$ec2*'" --output text)
  do
    echo $(aws ec2 describe-instances --instance-ids $instance_id --region $region --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`]|[0].Value]' --output text);
  done
  echo " ";
}

#Search again if the wrong EC2 was selected at first
check_instance () {
  date=`date +%m-%d-%Y`
  #region=us-east-1
  
  read -p "Enter EC2 instances: " ec2
  echo " ";
  
  for instance_id in $(aws ec2 describe-instances --region $region --query 'Reservations[*].Instances[*].[InstanceId]' --filters "Name=tag:Name,Values='*$ec2*'" --output text)
  do
    echo $(aws ec2 describe-instances --instance-ids $instance_id --region $region --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`]|[0].Value]' --output text);
  done
  echo " ";
}

create_ami () {
  # Get EC2 instance ID
  for instance_id in $(aws ec2 describe-instances --region $region --query 'Reservations[*].Instances[*].[InstanceId]' --filters "Name=tag:Name,Values='*$ec2*'" --output text) 
  do
    # Get EC2 instance name
    instance_name=$(aws ec2 describe-instances --instance-ids $instance_id --region $region --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`]|[0].Value]' --output text)
    #Check if EC2 instance name exists
    if [ -z "$instance_name" ]; then
      echo -e "Instance ID $instance_id does not exist or there is no NameTag created"
    else
      # Create the AMI
	  ami_name=$(echo "$instance_name")
  	  ami_id=$(aws ec2 create-image --instance-id $instance_id --name $ami_name --no-reboot --region $region --output text --tag-specifications "ResourceType=image,Tags=[{Key=Name,Value=$ami_name}]" "ResourceType=snapshot,Tags=[{Key=Name,Value=$ami_name}]")
  	  if [ "$ami_id" != "" ]; then
		echo $ami_id > ami_$instance_name.txt
  	    echo "$ami_id >> created successfully from instance >> $instance_name"
  	  else
  	    echo -e "AMI creation failed from $instance_name ($instance_id). Please check!\n"
  	  fi
    fi
  done
  exit 0
}

begin_script

while true 
do
  read -p "EC2 instance(s) correct? Type y/n <enter>" check
  if [ $check == "y" ]; then
    create_ami
  else
    check_instance
  fi
done