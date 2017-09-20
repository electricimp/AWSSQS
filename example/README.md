# Example Instructions

This demo will show you how to send, receive and delete a message in an SQS (Simple Queue Service) queue.

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

## Setting up an IAM Policy

1. Select the ‘Services’ link at the top left of the page and them type `IAM` in the search line
1. Select ‘IAM Manage User Access and Encryption Keys’
1. Select ‘Policies’ from the menu on the left
1. Click on the ‘Create Policy’ button
1. Press ‘Select’ for ‘Policy Generator’
1. On the ‘Edit Permissions’ page do the following:
    1. Set ‘Effect’ to ‘Allow’
    1. Set ‘AWS Service’ to ‘Amazon SQS’
    1. Set ‘Actions’ to ‘All Actions’
    1. Enter the ARN taken from the ‘Setting up a Queue in AWS SQS’ step 9 into the ‘Amazon Resource Name (ARN)’ field
    1. Click on ‘Add Statement’
    1. Click on ‘Next Step’
1. Give your policy a name (for example, `allow-sqs`) and type it into the ‘Policy Name’ field
1. Click on ‘Create Policy’

## Setting up the IAM User

1. Select the ‘Services’ link at the top left of the page and them type `IAM` in the search line
1. Select ‘IAM Manage User Access and Encryption Keys’
1. Select ‘Users’ from the menu on the left
1. Click on ‘Add user’
1. Choose a user name (for example, `user-calling-sqs`)
1. Check ‘Programmatic access’ but not anything else
1. Click on the ‘Next: Permissions’ button
1. Click on the ‘Attach existing policies directly’ icon
1. Check ‘allow-sqs’ from the list of policies
1. Click on the ‘Next: Review’ button
1. Click on ‘Create user’
1. Note your Access Key ID and Secret Access Key

## Configure the API keys for SQS

At the top of *sample.agent.nut* there are four constants that need to be configured:

| Parameter | Description |
| --- | --- |
| *AWS_SQS_REGION* | Your AWS region (eg. `"us-west-2"`) |
| *AWS_SQS_ACCESS_KEY_ID* | IAM Access Key ID |
| *AWS_SQS_SECRET_ACCESS_KEY* | IAM Secret Access Key |
| *AWS_SQS_URL* | Your SQS queue URL |

The last three constants should be populated with the values gathered by performing the steps above.

The AWSSQS library is licensed under the [MIT License](../LICENSE).
