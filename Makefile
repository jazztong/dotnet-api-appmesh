export LAB_NAME=dotnet-api-appmesh

export PRODUCT_API=ProductApi
export USER_API=UserApi
export ORDER_API=OrderApi

export PRODUCT_REPO=product_api
export USER_REPO=user_api
export ORDER_REPO=order_api

export AWS_DEFAULT_REGION=ap-southeast-1
export ACCOUNT_NUMBER=$$(aws sts get-caller-identity --outpu  text --query 'Account')
export ECR_URL=${ACCOUNT_NUMBER}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

INFRA_PATH ?= infra

lab:
	docker build -t ${LAB_NAME} .

login-lab:
	docker run \
		-it \
		--rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ${PWD}:/aws \
		-p 5000:5000 \
		-p 80:80 \
		--entrypoint sh \
		--name ${LAB_NAME} \
		${LAB_NAME}

db-server:
	docker run -it --rm \
	--name appmesh-mysql \
	-p 3306:3306 \
	-e MYSQL_ROOT_PASSWORD=mypassword \
	mysql

redis:
	docker run -it --rm \
	--name appmesh-redis \
	-p 6379:6379 \
	redis

init:
	terraform init ${INFRA_PATH}

plan:
	terraform plan ${INFRA_PATH}

apply:
	terraform apply --auto-approve ${INFRA_PATH}

kill:
	terraform destroy --auto-approve ${INFRA_PATH}

repo:
	for r in '${ORDER_REPO}' '${USER_REPO}' '${PRODUCT_REPO}'; \
		do aws ecr create-repository --repository-name $$r --query 'repository.[repositoryName]' --output text; done;

login:
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_URL}

product-image:
	docker build --rm --pull -f src/${PRODUCT_API}/Dockerfile -t ${PRODUCT_REPO} .
	docker tag ${PRODUCT_REPO}:latest ${ECR_URL}/${PRODUCT_REPO}:latest
	docker push ${ECR_URL}/${PRODUCT_REPO}:latest

order-image:
	docker build --rm --pull -f src/${ORDER_API}/Dockerfile -t ${ORDER_REPO} .
	docker tag ${ORDER_REPO}:latest ${ECR_URL}/${ORDER_REPO}:latest
	docker push ${ECR_URL}/${ORDER_REPO}:latest

user-image:
	docker build --rm --pull -f src/${USER_API}/Dockerfile -t ${USER_REPO} .
	docker tag ${USER_REPO}:latest ${ECR_URL}/${USER_REPO}:latest
	docker push ${ECR_URL}/${USER_REPO}:latest

image:
	make product-image
	make order-image
	make user-image

clear-repo:
	aws ecr describe-repositories --repository-names '${ORDER_REPO}' '${USER_REPO}' '${PRODUCT_REPO}' \
		--query 'repositories[*].[repositoryName]' --output text | \
		while read line; \
			do \
			aws ecr list-images --repository-name $$line --query 'imageIds[*].[imageDigest]' --output text | \
			while read imageId; \
				do aws ecr batch-delete-image --repository-name $$line --image-ids imageDigest=$$imageId; \
				done; \
			aws ecr delete-repository --repository-name $$line; \
			done