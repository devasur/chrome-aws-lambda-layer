#!/bin/bash
set -e
rm -fr chrome-aws-lambda
git clone --depth=1 https://github.com/alixaxel/chrome-aws-lambda.git
cd chrome-aws-lambda
mkdir -p ../chrome-layer 
make ../chrome-layer/chrome_aws_node10x.zip
ls -lah ../chrome-layer/chrome_aws_node10x.zip
rm -fr ../chrome-aws-lambda
echo 'Layer created successfully!'