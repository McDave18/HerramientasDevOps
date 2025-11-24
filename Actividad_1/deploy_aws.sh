set -e

REGION="us-east-1"
INSTANCE_TYPE="t3.nano"
KEY_NAME="AMI-Actividad-1"
SECURITY_GROUP_ID="sg-01ea1ab17648e051c"
SUBNET_ID="subnet-021beb4df18cc35ed"

echo "Realizando build :) ..."
AMI_ID=$(packer build -machine-readable packer.pkr.hcl | awk -F, '$0 ~/artifact,0,id/ {print $6}' | sed 's/.*://')

echo "Realizando build :) ..."
aws ec2 run-instances \
  --region "$REGION" \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SECURITY_GROUP_ID" \
  --subnet-id "$SUBNET_ID" \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=auto-deploy-actividad-1}]" \
  | tee logs/aws_run_instances.log

echo "Build/Deploy finalizado. Validar en consola EC2"
