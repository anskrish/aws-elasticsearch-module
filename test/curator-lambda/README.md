This script will create zip file and upload to S3 bucket to manage the ES cluster indices log retention using curator function.

**Dependency**

  1. Access to Artifactory and repository: https://xxxxxx.jfrog.io/xxxxx/ and infra-lambda/curator-lambda-es
  2. Have API KEY to Artifactory
  3. Python 3.6
  4. Python virtualenv

| Name | Description | Required
| ------ | ------ | ------ |
| JFROG_ARTIFACTORY_API_KEY | Artifactory API KEY | yes |
| GIT_TAG_BASE_VERSION | Zip file version | yes |
| REVISION | Zip file revision number (for minor changes) | yes |

**Steps** 

**Step 1**. Clone the  repo

**Step 2**. Go to "./curator-lambda" folder and edit below file.

**Makefile**

### Update the version to next version when you make changes on code ###

```
GIT_TAG_BASE_VERSION=v1
REVISION=0
```

**Step 3**  Export the API Key as

- export JFROG_ARTIFACTORY_API_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 

**Step 4**  Run below steps.

- make clean-curator-lambda
- make build-curator-lambda
- make push-curator-lambda



