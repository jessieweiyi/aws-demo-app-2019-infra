AWS_REGION=ap-southeast-2
ENVIRONMENT := dev

SQS_LOCAL_PORT:=6000
SQS_QUEUE_NAME:=aws-demo-app-2019-jobs
S3_LOCAL_PORT:=4572
S3_BUCKET_NAME:=aws-demo-app-2019
DYNAMODB_LOCAL_PORT:=8000
DYNAMODB_TABLE_NAME:=aws-demo-app-2019-jobs

.PHONY: setup-mocks
setup-mocks:
	sleep 5 && \
	./mocks/setupMockS3Bucket.sh localhost $(S3_LOCAL_PORT) $(S3_BUCKET_NAME) && \
	./mocks/setupMockDBTable.sh localhost $(DYNAMODB_LOCAL_PORT) $(DYNAMODB_TABLE_NAME) && \
	./mocks/setupMockSQSQueue.sh localhost $(SQS_LOCAL_PORT) $(SQS_QUEUE_NAME) &

.PHONY: run-local-dev
run-local-dev: setup-mocks
	docker-compose up 

.PHONY: run-aws-components
run-aws-components: setup-mocks
	docker-compose up aws-localstack


FOLDER_CF_TEMPLATES := $(PWD)/aws

FILE_CF_TEMPLATE_NETWORK := network.yml
NETWORK_STACK_NAME := aws-demo-app-2019-network-$(ENVIRONMENT)
PROVISION_NETWORK_PARAMETERS := --stack-name $(NETWORK_STACK_NAME) \
	--template-body file://$(FOLDER_CF_TEMPLATES)/$(FILE_CF_TEMPLATE_NETWORK) \
	--parameters ParameterKey=Environment,ParameterValue=$(ENVIRONMENT) \
	--capabilities CAPABILITY_IAM \
	--region $(AWS_REGION)

.PHONY: create-network
create-network:
	aws cloudformation create-stack $(PROVISION_NETWORK_PARAMETERS)
	aws cloudformation wait stack-create-complete --stack-name $(NETWORK_STACK_NAME)

.PHONY: update-network
update-network:
	aws cloudformation update-stack $(PROVISION_NETWORK_PARAMETERS)
	aws cloudformation wait stack-update-complete --stack-name $(NETWORK_STACK_NAME)	

FILE_CF_TEMPLATE_CLUSTER := cluster.yml
CLUSTER_STACK_NAME := aws-demo-app-2019-cluster-$(ENVIRONMENT)
PROVISION_CLUSTER_PARAMETERS := --stack-name $(CLUSTER_STACK_NAME) \
	--template-body file://$(FOLDER_CF_TEMPLATES)/$(FILE_CF_TEMPLATE_CLUSTER) \
	--parameters ParameterKey=Environment,ParameterValue=$(ENVIRONMENT) \
	--parameters ParameterKey=NetworkStackName,ParameterValue=$(NETWORK_STACK_NAME) \
	--capabilities CAPABILITY_IAM \
	--region $(AWS_REGION)

.PHONY: create-cluster
create-cluster:
	aws cloudformation create-stack $(PROVISION_CLUSTER_PARAMETERS)
	aws cloudformation wait stack-create-complete --stack-name $(CLUSTER_STACK_NAME)

.PHONY: update-cluster
update-cluster:
	aws cloudformation update-stack $(PROVISION_CLUSTER_PARAMETERS)
	aws cloudformation wait stack-update-complete --stack-name $(CLUSTER_STACK_NAME)

PROVISION_SQS_QUEUE_NAME:=$(SQS_QUEUE_NAME)-$(ENVIRONMENT)
PROVISION_SQS_DEAD_LETTER_QUEUE_NAME:=$(SQS_QUEUE_NAME)-dead-letter-$(ENVIRONMENT)
PROVISION_S3_BUCKET_NAME:=$(S3_BUCKET_NAME)-$(ENVIRONMENT)
PROVISION_DYNAMODB_TABLE_NAME:=$(DYNAMODB_TABLE_NAME)-$(ENVIRONMENT)
AWS_SERVICES_STACK_NAME := aws-demo-app-2019-aws-services-$(ENVIRONMENT)
FILE_CF_TEMPLATE_AWS_SERVICES:=services.yml
PROVISION_AWS_SERVICES_PARAMETERS := --stack-name $(AWS_SERVICES_STACK_NAME) \
	--template-body file://$(FOLDER_CF_TEMPLATES)/$(FILE_CF_TEMPLATE_AWS_SERVICES) \
	--parameters ParameterKey=Environment,ParameterValue=$(ENVIRONMENT) \
			     ParameterKey=S3BucketName,ParameterValue=$(PROVISION_S3_BUCKET_NAME) \
				 ParameterKey=SQSQueueName,ParameterValue=$(PROVISION_SQS_QUEUE_NAME) \
				 ParameterKey=SQSDeadLetterQueueName,ParameterValue=$(PROVISION_SQS_DEAD_LETTER_QUEUE_NAME) \
				 ParameterKey=DynamoDBTableName,ParameterValue=$(PROVISION_DYNAMODB_TABLE_NAME) \
	--capabilities CAPABILITY_IAM \
	--region $(AWS_REGION)

.PHONY: create-aws-service
create-aws-services:
	aws cloudformation create-stack $(PROVISION_AWS_SERVICES_PARAMETERS)
	aws cloudformation wait stack-create-complete --stack-name $(AWS_SERVICES_STACK_NAME)

.PHONY: update-aws-services
update-aws-services:
	aws cloudformation update-stack $(PROVISION_AWS_SERVICES_PARAMETERS)
	aws cloudformation wait stack-update-complete --stack-name $(AWS_SERVICES_STACK_NAME)









