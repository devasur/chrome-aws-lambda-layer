A 'serverless' example of using [Chrome AWS Lambda](https://github.com/alixaxel/chrome-aws-lambda.git) as an [AWS Lambda Layer](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html).  This project uses [serverless framework](https://serverless.com/) to manage deployment.  You can directly use the "buildchromelayer.sh" script packaged in this project to create a pre-built layer.

Objective here are the 
1. Puppeteer should be usable in AWS Nodejs 10.x lambda runtime.  (this problem is solved nicely by @alixaxel)
2. We want to use chrome through a layer.  This choice will make sense if you have many lambdas that needs Puppeteer.

## How to test
1. clone project into your workspace.
2. run ./buildchromelayer.sh to create the lambda layer using latest [Chrome AWS Lambda](https://github.com/alixaxel/chrome-aws-lambda.git)
3. Deploy code to AWS Console.
4. Login to Lambda Console. Select deployed function.  Use Test option to confirm the deployment works.
    1. Create a new Test event
       ```json
        {
        "url": "https://github.com/alixaxel"
        }       
       ```
    2. Click Test.
    3. Check Output

## Gotchas

1. in serverless.yml I am using plugin [serverless-plugin-include-dependencies](https://www.npmjs.com/package/serverless-plugin-include-dependencies) to keep the function sizes as small as possible.

2. in serverless.yml we are excluding all heavy weights from getting into the lambda thorugh appropriate packaging.  This helps to keep the sizes of lambda small and manageable.
    ```yaml
        package:
        exclude:
        - layer/**
        - layer1/**
        - node_modules/**
        - node_modules/**/chrome-aws-lambda/**
    ```
3. Lambda execution environment is manipulated by [Chrome AWS Lambda](https://github.com/alixaxel/chrome-aws-lambda.git) during instantiation of the library.  This is necessary because of mismatch of some required library versions in AWS Linux 2.  In the future this environment may change.  So it is highly recommended that you keep a watch on updates to [Chrome AWS Lambda Github](https://github.com/alixaxel/chrome-aws-lambda.git).
    * Creates chromium executable by inflating (brotlli) chromium.br (target /tmp/chrmoium)
    * Creates missing *.so libraries by inflating aws.tar.br 
    * manipulates the LD_LIBRARY_PATH to ensure packaged Linux libraries are loaded in correct order so that Puppeteer works.
    * Uses an appropriate execution path to chromium that it creates 

4. You can manage a lambda layer through a path to a folder or using an artifact reference to a pre-built layer zip.  Here we are using the pre-built layer approach.  Also remember that there is a bit of post processing that happens using the files in your layer on every execution of Lambda.  This is a necessary evil.

    Creating Layer
    ```yaml
    layers:
        chromePreBuilt:
            package:
            artifact: chrome-layer/chrome_aws_node10x.zip    

    ```

    Referencing layer in function using {title cased layer name}  + LambdaLayer notation.
    ```yaml
    loadWithChromeAwsLambda:
        timeout: 120
        memorySize: 1024  
        layers:
        - { Ref: ChromePreBuiltLambdaLayer}
        handler: overloadedpuppeteer.loadChrome

    ```
