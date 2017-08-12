# AWSSQS - Amazon Simple Queue Service Library

The helper library to implement and perform
[Amazon SQS](https://aws.amazon.com/documentation/sqs/) actions from agent code.

To add this library to your model, add the following lines to
the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSQS.agent.lib.nut:1.0.0"
```

**Note: [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/)
must be included before the AWSSQS library to make it work.**

## Class Usage

### constructor(region, accessKeyId, secretAccessKey)
AWSSQS object constructor which takes the following parameters:

Parameter              | Type           | Description
---------------------- | -------------- | -----------
region                 | string         | AWS region (e.g. "us-west-2")
accessKeyId            | string         | IAM Access Key ID
secretAccessKey        | string         | IAM Secret Access Key

#### Example

```squirrel
const AWS_SQS_ACCESS_KEY_ID     = "YOUR_ACCESS_KEY_ID_HERE";
const AWS_SQS_SECRET_ACCESS_KEY = "YOUR_SECRET_ACCESS_KEY_ID_HERE";
const AWS_SQS_URL               = "YOUR_SQS_URL_HERE";
const AWS_SQS_REGION            = "YOUR_REGION_HERE";

// initialise the class
sqs <- AWSSQS(AWS_SQS_REGION, AWS_SQS_ACCESS_KEY_ID, AWS_SQS_SECRET_ACCESS_KEY);
```

## Class Methods

### action(actionType, params, cb)
Performs a specified action (e.g send a message) with the 
required parameters (`params`) for the specified `action`.

Parameter         |       Type     | Description
----------------- | -------------- | -----------
actionType        | string         | Type of the Amazon SQS action that you want to perform (see [table](#action-types) below for more details)
params            | table          | Table of parameters relevant to the action
cb                | function       | Callback function that takes one parameter (a response table)

#### Action Types

Action Type                                                               | Description
------------------------------------------------------------------------- | ----------------
[AWSSQS_ACTION_SEND_MESSAGE](#awssqs_action_send_message)                 | Delivers a message to a specified queue
[AWSSQS_ACTION_SEND_MESSAGE_BATCH](#awssqs_action_send_message_batch)     | Delivers up to ten messages to a specified queue
[AWSSQS_ACTION_RECEIVE_MESSAGE](#awssqs_action_receive_message)           | Retrieves one or more messages (up to 10) from a specified queue
[AWSSQS_ACTION_DELETE_MESSAGE](#awssqs_action_delete_message)             | Deletes the specified message from the specified queue
[AWSSQS_ACTION_DELETE_MESSAGE_BATCH](#awssqs_action_delete_message_batch) | Deletes up to ten messages from a specified queue

#### Action parameters

##### AWSSQS_ACTION_SEND_MESSAGE

Delivers a message to the specified queue.
Please view the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SendMessage.html) for more information

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)

Parameter                    | Type                        | Required | Default | Description
---------------------------- |---------------------------- |----------|-------- | ----------
QueueUrl                     | string                      | Yes      | N/A     | The URL of the Amazon SQS queue from which messages are deleted
DelaySeconds                 | integer                     | No       | null    | The number of seconds to delay a specific message. Valid values: 0 to 900.
MessageAttribute.`<N>`.Name  | string                      | No       | null    | See [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-message-attributes.html#message-attributes-items-validation) for more details
MessageAttribute.`<N>`.Value | string or integer or blob   | No       | null    | Message attributes allow you to provide structured metadata items (such as timestamps, geospatial data, signatures, and identifiers) about the message
MessageAttribute.`<N>`.Type  | string                      | No       | null    | Type of MessageAttribute.N.Value determined by MessageAttribute.N.Type
MessageBody                  | string                      | Yes      | N/A     | The message to send. The maximum string size is 256 KB.
MessageDeduplicationId       | string                      | No       | null    | This parameter applies only to FIFO (first-in-first-out) queues. The token used for deduplication of sent messages. If a message with a particular MessageDeduplicationId is sent successfully, any messages sent with the same MessageDeduplicationId are accepted successfully but aren't delivered during the 5-minute deduplication interval
MessageGroupId               | string                      | No       | null    | This parameter applies only to FIFO (first-in-first-out) queues.The tag that specifies that a message belongs to a specific message group. Messages that belong to the same message group are processed in a FIFO manner (however, messages in different message groups might be processed out of order)

##### Send Message Example

```squirrel
local sendParams = {
    "QueueUrl"    : "https://some.aws.sqs.url",
    "MessageBody" : "testMessage"
};

sqs.action(AWSSQS_ACTION_SEND_MESSAGE, sendParams, function(res) {
    server.log(http.jsonencode(res));
});
```

####  AWSSQS_ACTION_SEND_MESSAGE_BATCH

Delivers up to ten messages to the specified queue.
Please view the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SendMessageBatch.html) for more information

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)

Parameter                                | Type    | Required   | Description
-----------------------------------------|---------|------------|-----------
QueueUrl                                 | string  | Yes        | The URL of the Amazon SQS queue from which messages are deleted
SendMessageBatchRequestEntry.`<N>`.`<X>` | string  | Yes        | A list of SendMessageBatchResultEntry items. Where N is the message entry number and X is the SendMessageBatchResultEntry parameter.

where `SendMessageBatchRequestEntry` consists of:

Parameter                    | Type                        | Required | Default | Description
---------------------------- |---------------------------- |----------|-------- | ----------
DelaySeconds                 | integer                     | No       | null    | The number of seconds to delay a specific message. Valid values: 0 to 900.
MessageAttribute.`<N>`.Name  | string                      | No       | null    | See [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-message-attributes.html#message-attributes-items-validation) for more details
MessageAttribute.`<N>`.Value | string or integer or blob   | No       | null    | Message attributes allow you to provide structured metadata items (such as timestamps, geospatial data, signatures, and identifiers) about the message
MessageAttribute.`<N>`.Type  | string                      | No       | null    | Type of MessageAttribute.N.Value determined by MessageAttribute.N.Type
MessageBody                  | string                      | Yes      | N/A     | The message to send. The maximum string size is 256 KB.
MessageDeduplicationId       | string                      | No       | null    | This parameter applies only to FIFO (first-in-first-out) queues. The token used for deduplication of sent messages. If a message with a particular MessageDeduplicationId is sent successfully, any messages sent with the same MessageDeduplicationId are accepted successfully but aren't delivered during the 5-minute deduplication interval
MessageGroupId               | string                      | No       | null    | This parameter applies only to FIFO (first-in-first-out) queues.The tag that specifies that a message belongs to a specific message group. Messages that belong to the same message group are processed in a FIFO manner (however, messages in different message groups might be processed out of order)

##### Send Message Batch Example

```squirrel
local messageBatchParams = {
    "QueueUrl": "https://some.aws.sqs.url",
    "SendMessageBatchRequestEntry.1.Id": "m1",
    "SendMessageBatchRequestEntry.1.MessageBody": "testMessage1",
    "SendMessageBatchRequestEntry.2.Id": "m2",
    "SendMessageBatchRequestEntry.2.MessageBody": "testMessage2",
}
sqs.action(AWSSQS_ACTION_SEND_MESSAGE_BATCH, messageBatchParams, function(res) {
    server.log(res.statuscode);
});
```

#### AWSSQS_ACTION_RECEIVE_MESSAGE

Retrieves one or more messages (up to 10), from the specified queue.
Please view the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_ReceiveMessage.html) for more information

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)

Parameter                   | Type                 | Required | Default | Description
--------------------------- | -------------------- | -------- | ------- | -----
QueueUrl                    | string               | Yes      | N/A     | The URL of the Amazon SQS queue from which messages are deleted
AttributeName.`<N>`         | array of strings     | No       | null    | A list of attributes that need to be returned along with each message. See api document for details
MaxNumberOfMessages         | integer              | No       | null    | The maximum number of messages to return. Between 1 and 10 messages may be selected to be returned
MessageAttributeName.`<N>`  | array of strings     | No       | null    | The name of the message attribute, where N is the index
ReceiveRequestAttemptId     | string               | No       | null    | This parameter applies only to FIFO (first-in-first-out) queues.The token used for deduplication of ReceiveMessage calls. If a networking issue occurs after a ReceiveMessage action, and instead of a response you receive a generic error, you can retry the same action with an identical ReceiveRequestAttemptId
VisibilityTimeout           | integer              | No       | null    | The duration (in seconds) that the received messages are hidden from subsequent retrieve requests after being retrieved by a ReceiveMessage request
WaitTimeSeconds             | integer              | No       | null    | The duration (in seconds) for which the call waits for a message to arrive in the queue before returning. If a message is available, the call returns sooner than WaitTimeSeconds

##### Receive Message Example

```squirrel
local receiptFinder = function(messageBody) {
    local start   = messageBody.find("<ReceiptHandle>");
    local finish  = messageBody.find("/ReceiptHandle>");
    local receipt = messageBody.slice((start + 15), (finish - 1));
    return receipt;
}

// Receive Message
local receiveParams = {
    "QueueUrl": "https://some.aws.sqs.url"
}
sqs.action(AWSSQS_ACTION_RECEIVE_MESSAGE, receiveParams, function(res) {
    if (res.statuscode >= 200 && res.statuscode < 300) {
        server.log(receiptFinder(res.body));
    }
});
```

#### AWSSQS_ACTION_DELETE_MESSAGE

Deletes the specified message from the specified queue. You specify the message by using the message's receipt handle and not the MessageId you receive when you send the message.
Please view the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_DeleteMessage.html) for more information

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)

Parameter    | Type    |Required | Description
-------------|-------- |-------- |--------------------------
QueueUrl     | string  | Yes     | The URL of the Amazon SQS queue from which messages are deleted
ReceiptHandle| string  | Yes     | The receipt handle associated with the message to delete

##### Delete Message Example

Please refer to the Receive Message [example](#receive-message-example) for how to obtain RECEIPT_HANDLE.

```squirrel
deleteParams <- {
    "QueueUrl": "https://some.aws.sqs.url"
    "ReceiptHandle": "RECEIPT_HANDLE"
}
sqs.action(AWSSQS_ACTION_DELETE_MESSAGE, deleteParams, function(res) {
    server.log(res.statuscode);
});
```

#### AWSSQS_ACTION_DELETE_MESSAGE_BATCH

Deletes up to ten messages from the specified queue. This is a batch version of DeleteMessage. The result of the action on each message is reported individually in the response.
Please view the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_DeleteMessageBatch.html) for more information

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)

Parameter                                  | Type    | Required | Description
-------------------------------------------|-------- |--------  |--------------------------
QueueUrl                                   | string  | Yes      | The URL of the Amazon SQS queue from which messages are deleted
DeleteMessageBatchRequestEntry.`<N>`.`<X>` | string  | Yes      | A list of DeleteMessageBatchResultEntry items. Where N is the message entry number and X is the SendMessageBatchResultEntry parameter.


where `DeleteMessageBatchRequestEntry` consists of:

Parameter     | Type    | Required | Description
------------- |-------- |--------  | --------------------------
Id            | string  | Yes      | An identifier for this particular receipt handle.
ReceiptHandle | string  | Yes      | The receipt handle associated with the message to delete

##### Delete Message Batch Example

Please refer to the Receive Message [example](#receive-message-example) for how to obtain RECEIPT_HANDLE.
Please refer to the Send Message Batch [example](#send-message-batch-example) for where the batch of messages were placed

```squirrel
local deleteParams = {
    "QueueUrl": "https://some.aws.sqs.url",
    "DeleteMessageBatchRequestEntry.1.Id": "m1"
    "DeleteMessageBatchRequestEntry.1.ReceiptHandle": receipt,
}

_sqs.action(AWSSQS_ACTION_DELETE_MESSAGE_BATCH, deleteParams, function(res) {
    server.log(res.statuscode);
});
```

### Response Table

The format of the response table is general for all actions:

Key                   |       Type     | Description
--------------------- | -------------- | -----------
body                  | string         | AWS SQS response in a function specific structure that is json encoded.
statuscode            | integer        | http status code
headers               | table          | see headers

where `headers` table consists of:

Key                   |       Type       | Description
--------------------- | --------------   | -----------
x-amzn-requestid      | string           | Amazon request id
content-type          | string           | Content type e.g text/XML
date                  | string           | The date and time at which response was sent
content-length        | string           | the length of the content
x-amz-crc32           | string           | Checksum of the UTF-8 encoded bytes in the HTTP response

# License

The AWSSQS library is licensed under the [MIT License](LICENSE).
