#!/bin/bash
set -e

# Get 'RegionName' of all the Regions that are enabled for your account
ENABLED_REGIONS="$(aws ec2 describe-regions | jq -r .Regions[].RegionName)"

for REGION in $ENABLED_REGIONS; do
    echo "Checking resources for region: ${REGION}"
    
    # Get the ID of the default VPC for the region
    DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --region ${REGION} --filters Name=isDefault,Values=true | jq -r .Vpcs[0].VpcId)
    
    if [ "$DEFAULT_VPC_ID" == "null" ]
    then
        echo "No default VPC found for ${REGION}"
        continue
    else
        echo "Default VPC for ${REGION}: ${DEFAULT_VPC_ID}"
    fi

    # Get default IG then detach/delete
    DEFAULT_IG_ID=$(aws ec2 describe-internet-gateways --region ${REGION} --filter Name=attachment.vpc-id,Values=${DEFAULT_VPC_ID} | jq -r .InternetGateways[0].InternetGatewayId)

    if [ "$DEFAULT_IG_ID" != "null" ]
    then
        echo "Detaching and deleting default internet gateway for region ${REGION}: ${DEFAULT_IG_ID}"
        aws ec2 detach-internet-gateway --region ${REGION} --internet-gateway-id ${DEFAULT_IG_ID} --vpc-id ${DEFAULT_VPC_ID}
        aws ec2 delete-internet-gateway --region ${REGION} --internet-gateway-id ${DEFAULT_IG_ID}
    fi

    # Get default subnets then delete
    DEFAULT_SUBNET_ID=$(aws ec2 describe-subnets --region ${REGION} --filters Name=vpc-id,Values=${DEFAULT_VPC_ID} | jq -r .Subnets[].SubnetId)

    if [ "$DEFAULT_SUBNET_ID" != "null" ]
    then
        for SUBNET_ID in ${DEFAULT_SUBNET_ID}; do
            echo "Deleting subnet for ${REGION}: ${SUBNET_ID}"
            aws ec2 delete-subnet --region ${REGION} --subnet-id ${SUBNET_ID}
        done
    fi

    # Delete default vpc
    echo "Deleting default VPC for ${REGION}: ${DEFAULT_VPC_ID}"
    aws ec2 delete-vpc --region ${REGION} --vpc-id ${DEFAULT_VPC_ID}

    # Get default dhcp options then delete
    DEFAULT_DHCP_OPTS_ID=$(aws ec2 describe-dhcp-options --region ${REGION} | jq -r .DhcpOptions[0].DhcpOptionsId)
    if [ "$DEFAULT_DHCP_OPTS_ID" != "None" ]
    then
        echo "Deleting default DHCP Options for ${REGION}: ${DEFAULT_DHCP_OPTS_ID}"
        aws ec2 delete-dhcp-options --region ${REGION} --dhcp-options-id ${DEFAULT_DHCP_OPTS_ID}
    fi
done
