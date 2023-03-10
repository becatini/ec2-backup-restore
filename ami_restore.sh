#!/bin/bash  
##################################################
# Script to restore EC2 instance after migration #
##################################################

true > sg.txt

read -p "Enter region: " region
read -p "Enter EC2 instance to be restored: " ec2
#echo " ";

file=$ec2.txt
if [ ! -f $file ]; then
	echo "EC2 instance name not found!"
else
	#Declare variables
	a=1
	ami_id=$(cat ami_$ec2.txt)
	instance_type=$(cat $ec2.txt |grep InstanceType | cut -d "\"" -f4)
	key_pair=$(cat $ec2.txt |grep KeyPair | cut -d "\"" -f4)
	subnet_id=$(cat $ec2.txt |grep SubnetId | cut -d "\"" -f4)
	private_ip=$(cat $ec2.txt | awk 'c&&!--c;/PrivateIP":/{c='$a'}' | awk -F\" '{print $2}')
	instance_name=$(cat $ec2.txt |grep InstanceName | cut -d "\"" -f4)
	
	b=$(cat $ec2.txt | awk 'c&&!--c;/eniSGId":/{c='$a'}')
	eniSGId=$(cat $ec2.txt | awk 'c&&!--c;/eniSGId":/{c='$a'}' | awk -F\" '{print $2}')
	while [ $b != "]" ]
	do
	if [ $b != "]" ]; then
		a=$(expr $a + 1)    	
		b=$(cat $ec2.txt | awk 'c&&!--c;/eniSGId":/{c='$a'}')
	fi  
	done
	
	for ((i=1;i<$a;i++))
	do 
	echo -n $(cat $ec2.txt | awk 'c&&!--c;/eniSGId":/{c='$i'}' | awk -F\" '{print $2}') "" >>sg.txt
	done
		
	#Check if there is a key pair before creating the EC2 instance
	if [ ! -z $key_pair ]; then
		aws ec2 run-instances --image-id $ami_id --count 1 --instance-type $instance_type --key-name $key_pair --security-group-ids $(cat sg.txt) --subnet-id $subnet_id --private-ip-address $private_ip --region $region --tag-specifications ResourceType=instance,Tags="[{Key=Name,Value=$instance_name}]" >/dev/null
	else
		aws ec2 run-instances --image-id $ami_id --count 1 --instance-type $instance_type --security-group-ids $(cat sg.txt) --subnet-id $subnet_id --private-ip-address $private_ip --region $region --tag-specifications ResourceType=instance,Tags="[{Key=Name,Value=$instance_name}]" >/dev/null
	fi
fi

