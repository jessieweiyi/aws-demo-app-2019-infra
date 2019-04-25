AWS_REGION=ap-southeast-2
FOLDER_CF_TEMPLATES := $(PWD)/aws
FILE_CF_TEMPLATE_CLUSTER := cluster.yml
ENVIRONMENT := dev

CLUSTER_STACK_NAME := aws-demo-app-2019-cluster-${ENVIRONMENT}
ifeq (dev, $(ENVIRONMENT))
endif

ifeq (prod, $(ENVIRONMENT))
endif

PROVISION_CLUSTER_PARAMETERS := --stack-name ${CLUSTER_STACK_NAME} --template-body file://${FOLDER_CF_TEMPLATES}/${FILE_CF_TEMPLATE_CLUSTER} --parameters ParameterKey=Environment,ParameterValue=${ENVIRONMENT} --capabilities CAPABILITY_IAM --region ${AWS_REGION}

.PHONY: create-cluster
create-cluster:
	aws cloudformation create-stack ${PROVISION_CLUSTER_PARAMETERS}
	aws cloudformation wait stack-create-complete --stack-name ${CLUSTER_STACK_NAME}

.PHONY: update-cluster
update-cluster:
	aws cloudformation update-stack ${PROVISION_CLUSTER_PARAMETERS}
	aws cloudformation wait stack-update-complete --stack-name ${CLUSTER_STACK_NAME}

.PHONY: create-dynamodb-table
create-dynamodb-table:
	aws dynamodb create-table --endpoint-url http://localhost:8000 --table-name jobs --attribute-definitions AttributeName=jobId,AttributeType=S --key-schema AttributeName=jobId,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

