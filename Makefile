AWS_REGION=ap-southeast-2
FOLDER_CF_TEMPLATES := $(PWD)/aws
FILE_CF_TEMPLATE_CLUSTER := cluster.yml
ENVIRONMENT := dev

DYNAMODB_LOCAL_HOST=localhost
DYNAMODB_LOCAL_PORT=8000
DYNAMODB_TABLE_NAME=jobs

.PHONY: setup-mocks
setup-mocks:
	./mocks/setupMockDBTable.sh ${DYNAMODB_LOCAL_HOST} ${DYNAMODB_LOCAL_PORT} ${DYNAMODB_TABLE_NAME} &

.PHONY: run-local-dev
run-local-dev: setup-mocks
	docker-compose up 

.PHONY: run-aws-components
run-aws-components: setup-mocks
	docker-compose up aws-s3-local aws-sqs-local aws-dynamodb-local

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



