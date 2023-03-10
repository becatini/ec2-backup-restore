#!/bin/bash  
###########################################
# Script to backup EC2 data for migration #
###########################################

#region=us-east-1
#ec2=service-restored
read -p "Enter region: " region
read -p "Enter EC2 instances: " ec2
echo " ";

#Search the instances that will be used to create the AMI
for instance_id in $(aws ec2 describe-instances --region $region --query 'Reservations[*].Instances[*].[InstanceId]' --filters "Name=tag:Name,Values='*$ec2*'" --output text)
do
  #Declare $instance_name
  instance_name=$(aws ec2 describe-instances --instance-ids $instance_id --region $region --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`]|[0].Value]' --output text)
  
  #Generate a txt file from all requested EC2 instances
  aws ec2 describe-instances --region $region --query 'Reservations[*].Instances[*].{InstanceName: Tags[?Key==`Name`]|[0].Value, InstanceId: InstanceId, KeyPair: KeyName, InstanceType: InstanceType, SubnetId: SubnetId, VpcId: VpcId, PrivateIP: NetworkInterfaces[*].PrivateIpAddress, EniId: NetworkInterfaces[*].NetworkInterfaceId, eniSG: NetworkInterfaces[*].Groups[*].GroupName[], eniSGId: NetworkInterfaces[*].Groups[*].GroupId[]}' --filters "Name=tag:Name,Values='*$ec2*'" >ec2_data_backup.txt
  
  #Generate one text file from each requested EC2 instances. 
  #That will be used to create the EC2 from the AMI if necessary a rollback
  aws ec2 describe-instances --region $region --query 'Reservations[*].Instances[*].{InstanceName: Tags[?Key==`Name`]|[0].Value, InstanceId: InstanceId, KeyPair: KeyName, InstanceType: InstanceType, SubnetId: SubnetId, VpcId: VpcId, PrivateIP: NetworkInterfaces[*].PrivateIpAddress, EniId: NetworkInterfaces[*].NetworkInterfaceId, eniSG: NetworkInterfaces[*].Groups[*].GroupName[], eniSGId: NetworkInterfaces[*].Groups[*].GroupId[]}' --filters "Name=tag:Name,Values='*$instance_name*'" >$instance_name.txt
done