#!/bin/bash

#set directory

dir_name=lambda_pkg_/
source_code_path=./code
mkdir $dir_name

#virtual env setup

virtualenv -p python3 env
source env/bin/activate

#installing python dependencies
FILE=$source_code_path/requirements.txt
if [ -f $FILE ]; then
  echo "requirement.txt file exists in source_code_path. Installing dependencies.."
  pip install -q -r $FILE --upgrade
else
  echo "requirement.txt file does not exist. Skipping installation of dependencies."
fi

python_version=$(echo $(python --version) | awk -F" " '{print $2}' | awk -F"." '{print $1"."$2}')
#deactivate virtualenv
deactivate

#creating deployment package
cp -r ./env/lib/python$python_version/site-packages/* ./$dir_name
pwd
cp -r $source_code_path/* ./$dir_name
cd ./$dir_name
zip -r ../lambda.zip *
sha_256=$(openssl dgst -sha256 ../lambda.zip|sed 's/^SHA256.*= //')
sha1=$(openssl dgst -sha1 ../lambda.zip|sed 's/^SHA.*= //')
echo $sha_256 > ../lambda.sha256
echo $sha1 > ../lambda.sha1

#removing virtual env folder

rm -rf ../env
