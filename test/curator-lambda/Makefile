ARTIFACTORY_BASE_URL=https://xxxxx.jfrog.io/xxxxx/infra-lambda/curator-lambda-es
GIT_TAG_BASE_VERSION=v1
REVISION=0
ZIPFILE=lambda.zip
ARTIFACTORY_ZIPFILE="lambda-${GIT_TAG_BASE_VERSION}.${REVISION}.zip"

ifneq ("lambda.sha256","")
	sha_256=$(shell cat lambda.sha256)
endif

ifneq ("lambda.sha1","")
	sha_1=$(shell cat lambda.sha1)
endif

	
clean-curator-lambda:
		rm -rf lambda*
build-curator-lambda:
		bash python-package-dependency.sh
push-curator-lambda:
		curl -s -H "X-JFrog-Art-Api:${JFROG_ARTIFACTORY_API_KEY}" -T ${ZIPFILE} -H "X-Checksum-Sha256:${sha_256}" -H "X-Checksum-Sha1:${sha_1}" "${ARTIFACTORY_BASE_URL}/${GIT_TAG_BASE_VERSION}.${REVISION}/${ARTIFACTORY_ZIPFILE}"

