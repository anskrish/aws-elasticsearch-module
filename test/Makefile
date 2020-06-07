TERRAFORM=terraform
USER=$(shell id -un)
ARTIFACTORY_BASE_URL=https://xxxxxx.jfrog.io/xxxx/infra-lambda/curator-lambda-es
GIT_TAG_BASE_VERSION=v1
REVISION=0

all: pull-curator-lambda-es apply

apply: 
	$(TERRAFORM) init
	$(TERRAFORM) apply

pull-curator-lambda-es:
	curl -s -L -H "X-JFrog-Art-Api:${JFROG_ARTIFACTORY_API_KEY}" -O ${ARTIFACTORY_BASE_URL}/${GIT_TAG_BASE_VERSION}.${REVISION}/lambda-${GIT_TAG_BASE_VERSION}.${REVISION}.zip

	
clean:
	$(TERRAFORM) init
	$(TERRAFORM) destroy
	rm -fr .terraform terraform.tfstate terraform.tfstate.backup

