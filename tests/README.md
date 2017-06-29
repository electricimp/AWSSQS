# Test Instructions

The instructions will show you how to set up the tests for AWS SQS.

As the sample code includes the private key verbatim in the source, it should be treated carefully, and not checked into version control!

## Setting up a Queue in AWS SQS

1. Go to the sqs console  
1. Click "Create New Queue"
1. Enter in testQueue in the "Queue Name" section
1. Note your AWS region
1. Select "Standard Queue"
1. Click "Quick-Create Queue"
1. Note the URL of your select SQS queue.

## Configure the API keys for SQS

At the top of the agent.test.nut there are four constants that need to be configured.

Parameter                   | Description
--------------------------- | -----------
AWS_TEST_REGION     		| AWS region (e.g. "us-west-2")
AWS_TEST_ACCESS_KEY_ID      | IAM Access Key ID
AWS_TEST_SECRET_ACCESS_KEY  | IAM Secret Access Key
AWS_TEST_SQS_URL			| Your SQS queue URL

## Imptest
 Please ensure that the `.imptest` agent file includes both AWSRequestV4 library and the AWSSQS class.

# License

 The AWSSQS library is licensed under the [MIT License](../LICENSE).
