# Test Instructions

The instructions will show you how to set up the tests for AWS SQS.

**Note** The sample code includes the private key verbatim in the source, so it should be treated carefully and not checked into version control.

## Setting up a Queue in AWS SQS

1. Login to the [AWS console](https://aws.amazon.com/console/)
1. Select ‘Services link’ (on the top left of the page) and then type ‘SQS’ in the search line
1. Select ‘Simple Queueing Service’
1. Click on ‘Create New Queue’ (or ‘Get Started Now’ of you haven’t used the service before)
1. Enter `testQueue` into the ‘Queue Name’ section
1. Note your AWS region
1. Select ‘Standard Queue’
1. Click on ’Quick-Create Queue’
1. Note the URL and the ARN of the SQS queue you are using

## Configure the API Keys for SQS

At the top of *sample.agent.nut* there are four constants that need to be configured:

| Parameter | Description |
| --- | --- |
| *AWS_SQS_REGION* | Your AWS region (eg. `"us-west-2"`) |
| *AWS_SQS_ACCESS_KEY_ID* | IAM Access Key ID |
| *AWS_SQS_SECRET_ACCESS_KEY* | IAM Secret Access Key |
| *AWS_SQS_URL* | Your SQS queue URL |

## ImpTest

Please ensure that the *.imptest* agent file `#require`s both the AWSRequestV4 library and the AWSSQS class.

## License

The AWSSQS library is licensed under the [MIT License](../LICENSE).
