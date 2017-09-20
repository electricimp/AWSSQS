# AWSSQS &mdash; Amazon Simple Queue Service Library

[![Build Status](https://api.travis-ci.org/electricimp/AWSSQS.svg?branch=master)](https://travis-ci.org/electricimp/AWSSQS)

This library allows [Amazon SQS](https://aws.amazon.com/documentation/sqs/) actions to be performed by agent code.

To add this library to your model, add the following lines to the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSQS.agent.lib.nut:1.0.0"
```

The [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be included **before** the AWSSQS library.

## Class Usage

### Constructor: AWSSQS(*region, accessKeyId, secretAccessKey*)

WSSQS object constructor which takes the following parameters:

Parameter         | Type   | Description
----------------- | ------ | -----------
*region*          | String | AWS region (eg. `"us-west-2"`)
*accessKeyId*     | String | IAM Access Key ID
*secretAccessKey* | String | IAM Secret Access Key

#### Example

```squirrel
const AWS_SQS_ACCESS_KEY_ID     = "<YOUR_ACCESS_KEY_ID_HERE>";
const AWS_SQS_SECRET_ACCESS_KEY = "<YOUR_SECRET_ACCESS_KEY_HERE>";
const AWS_SQS_URL               = "<YOUR_SQS_URL_HERE>";
const AWS_SQS_REGION            = "<YOUR_REGION_HERE>";

// Initialize the class
sqs <- AWSSQS(AWS_SQS_REGION, AWS_SQS_ACCESS_KEY_ID, AWS_SQS_SECRET_ACCESS_KEY);
```

## Class Methods

### action(*actionType, params, callback*) ###

Performs the specified action (eg. ‘send a message’) with the required parameters.

Parameter    | Type     | Description
------------ | -------- | -----------
*actionType* | Constant | Type of Amazon SQS action that you want to perform (see [‘Action Types’](#action-types) below for more details)
*params*     | Table    | Table of parameters relevant to the action *(see below)*
*callback*   | Function | Callback function that takes one parameter (a response table)

#### Action Types

Action Type                                                               | Description
------------------------------------------------------------------------- | -----------
[*AWSSQS_ACTION_SEND_MESSAGE*](#awssqs_action_send_message)                 | Delivers a message to a specified queue
[*AWSSQS_ACTION_SEND_MESSAGE_BATCH*](#awssqs_action_send_message_batch)     | Delivers up to ten messages to a specified queue
[*AWSSQS_ACTION_RECEIVE_MESSAGE*](#awssqs_action_receive_message)           | Retrieves one or more messages (up to 10) from a specified queue
[*AWSSQS_ACTION_DELETE_MESSAGE*](#awssqs_action_delete_message)             | Deletes the specified message from the specified queue
[*AWSSQS_ACTION_DELETE_MESSAGE_BATCH*](#awssqs_action_delete_message_batch) | Deletes up to ten messages from a specified queue

#### Action Parameters

##### *AWSSQS_ACTION_SEND_MESSAGE*

Delivers a message to the specified queue. Please view the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SendMessage.html) for more information.

Parameter | Type | Required? | Default | Description
--- | --- | --- | --- | --- 
*QueueUrl* | String | Yes | N/A | The URL of the Amazon SQS queue from which messages are sent
*DelaySeconds* | Integer | No | `null` | The number of seconds to delay a specific message. Valid values: 0 to 900
*MessageAttribute.<N>.Name* | String | No | `null` | See the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-message-attributes.html#message-attributes-items-validation) for more details
*MessageAttribute.<N>.Value* | String, integer or blob | No | `null` | Message attributes allow you to provide structured metadata (such as timestamps, geospatial data, signatures nd identifiers) about the message
*MessageAttribute.<N>.Type* | String | No | `null` | Type of *MessageAttribute.<N>.Value* determined by *MessageAttribute.<N>.Type*
*MessageBody* | String | Yes | N/A | The message to send. The maximum string size: 256KB
*MessageDeduplicationId* | String | No | `null` | This parameter applies only to FIFO (first in, first out) queues. The token used for deduplication of sent messages. If a message with a particular *MessageDeduplicationId* is sent successfully, any messages sent with the same *MessageDeduplicationId* are accepted successfully but aren’t delivered during the five-minute deduplication interval
*MessageGroupId* | String | No | `null` | This parameter applies only to FIFO (first in, first out) queues. The tag that specifies that a message belongs to a specific message group. Messages that belong to the same message group are processed in a FIFO manner (messages in different message groups might be processed out of order)

##### Example

```squirrel
local sendParams = {
    "QueueUrl"    : "https://some.aws.sqs.url",
    "MessageBody" : "testMessage"
};

sqs.action(AWSSQS_ACTION_SEND_MESSAGE, sendParams, function(response) {
    server.log(http.jsonencode(response));
});
```

##### *AWSSQS_ACTION_SEND_MESSAGE_BATCH*

Delivers up to ten messages to the specified queue. Please view the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SendMessageBatch.html) for more information.

Parameter | Type | Required? | Description
--- | --- | --- | ---
*QueueUrl* | String | Yes | The URL of the Amazon SQS queue from which messages are sent
*SendMessageBatchRequestEntry.<N>.<X>* | String | Yes | A list of *SendMessageBatchResultEntry* items. Where <N> is the message entry number and <x> is the *SendMessageBatchResultEntry* parameter. *SendMessageBatchRequestEntry*s consist of:

Parameter | Type | Required? | Default | Description
--- | --- | --- | --- | --- 
*DelaySeconds* | Integer | No | `null` | The number of seconds to delay a specific message. Valid values: 0 to 900
*MessageAttribute.<N>.Name* | String | No | `null` | See the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-message-attributes.html#message-attributes-items-validation) for more details
*MessageAttribute.<N>.Value* | String, integer or blob | No | `null` | Message attributes allow you to provide structured metadata (such as timestamps, geospatial data, signatures nd identifiers) about the message
*MessageAttribute.<N>.Type* | String | No | `null` | Type of *MessageAttribute.<N>.Value* determined by *MessageAttribute.<N>.Type*
*MessageBody* | String | Yes | N/A | The message to send. The maximum string size: 256KB
*MessageDeduplicationId* | String | No | `null` | This parameter applies only to FIFO (first in, first out) queues. The token used for deduplication of sent messages. If a message with a particular *MessageDeduplicationId* is sent successfully, any messages sent with the same *MessageDeduplicationId* are accepted successfully but aren’t delivered during the five-minute deduplication interval
*MessageGroupId* | String | No | `null` | This parameter applies only to FIFO (first in, first out) queues. The tag that specifies that a message belongs to a specific message group. Messages that belong to the same message group are processed in a FIFO manner (messages in different message groups might be processed out of order)

##### Example

```squirrel
local messageBatchParams = {
    "QueueUrl": "https://some.aws.sqs.url",
    "SendMessageBatchRequestEntry.1.Id": "m1",
    "SendMessageBatchRequestEntry.1.MessageBody": "testMessage1",
    "SendMessageBatchRequestEntry.2.Id": "m2",
    "SendMessageBatchRequestEntry.2.MessageBody": "testMessage2",
};

sqs.action(AWSSQS_ACTION_SEND_MESSAGE_BATCH, messageBatchParams, function(response) {
    server.log(response.statuscode);
});
```

#### *AWSSQS_ACTION_RECEIVE_MESSAGE*

Retrieves one or more messages (up to ten), from the specified queue. Please view the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_ReceiveMessage.html) for more information.

Parameter | Type | Required? | Default | Description
--- | --- | --- | --- | --- 
*QueueUrl* | String | Yes | N/A | The URL of the Amazon SQS queue from which messages are received
*AttributeName.<N>* | Array of strings | No | `null` | A list of attributes that need to be returned along with each message. See the linked document above for details
*MaxNumberOfMessages* | Integer | No | `null` | The maximum number of messages to return. Between one and ten messages may be selected to be returned 
*MessageAttributeName.<N>* | Array of strings | No | `null` | The name of the message attribute, where <N> is the index
*ReceiveRequestAttemptId* | String | No | `null` | This parameter applies only to FIFO (first in, first out) queues. The token used for deduplication of ReceiveMessage calls. If a networking issue occurs after a ReceiveMessage action, and you receive a generic error, you can retry the same action with an identical *ReceiveRequestAttemptId*
*VisibilityTimeout* | Integer | No | `null` | The duration (in seconds) that the received messages are hidden from subsequent retrieve requests after being retrieved by a ReceiveMessage request
*WaitTimeSeconds* | Integer | No | `null` | The duration (in seconds) for which the call waits for a message to arrive in the queue before returning. If a message is available, the call returns sooner than *WaitTimeSeconds*

##### Example

```squirrel
local receiptHandleFinder = function(messageBody) {
    local start   = messageBody.find("<ReceiptHandle>");
    local finish  = messageBody.find("/ReceiptHandle>");
    local receipt = messageBody.slice((start + 15), (finish - 1));
    return receiptHandle;
};

// Receive Message
local receiveParams = {
    "QueueUrl": "https://some.aws.sqs.url"
};

sqs.action(AWSSQS_ACTION_RECEIVE_MESSAGE, receiveParams, function(response) {
    if (response.statuscode >= 200 && response.statuscode < 300) {
        server.log(receiptHandleFinder(response.body));
    }
});
```

#### *AWSSQS_ACTION_DELETE_MESSAGE*

Deletes the specified message from the specified queue. You specify the message by using the message’s receipt handle and not the *MessageId* you receive when you send the message. Please view the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_DeleteMessage.html) for more information.

Parameter | Type | Required? | Description
--- | --- | --- | ---
*QueueUrl* | String | Yes | The URL of the Amazon SQS queue from which messages are deleted
*ReceiptHandle* | String | Yes | The receipt handle associated with the message to delete

##### Example

Please refer to the Receive Message example, above, to see how you obtain *receiptHandle*.

```squirrel
deleteParams <- {
    "QueueUrl": "https://some.aws.sqs.url",
    "ReceiptHandle": receiptHandle
}

sqs.action(AWSSQS_ACTION_DELETE_MESSAGE, deleteParams, function(receiptHandle) {
    server.log(receiptHandle.statuscode);
});
```

#### *AWSSQS_ACTION_DELETE_MESSAGE_BATCH*

Deletes up to ten messages from the specified queue. This is a batch version of DeleteMessage. The result of the action on each message is reported individually in the response. Please view the [AWS SQS documentation](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_DeleteMessageBatch.html) for more information.

Parameter | Type | Required? | Description
--- | --- | --- | ---
*QueueUrl* | String | Yes | The URL of the Amazon SQS queue from which messages are deleted
*DeleteMessageBatchRequestEntry.<N>.<X>* | String | Yes | A list of *DeleteMessageBatchResultEntry* items where <N> is the message entry number and <X> is the *SendMessageBatchResultEntry* parameter. *DeleteMessageBatchRequestEntry*s consist of:

Parameter | Type | Required? | Description
--- | --- | --- | ---
*Id* | String | Yes | An identifier for this particular receipt handle
*ReceiptHandle* | String | Yes | The receipt handle associated with the message to be deleted

##### Example

Please refer to the Receive Message example, above, to see how you obtain *receiptHandle*, and to the Send Message Batch example, above, to learn where the batch of messages were placed.

```squirrel
local deleteParams = {
    "QueueUrl": "https://some.aws.sqs.url",
    "DeleteMessageBatchRequestEntry.1.Id": "m1",
    "DeleteMessageBatchRequestEntry.1.ReceiptHandle": receiptHandle
}

sqs.action(AWSSQS_ACTION_DELETE_MESSAGE_BATCH, deleteParams, function(response) {
    server.log(response.statuscode);
});
```

### Action Response Table

The format of the response table is common to all actions:

Key | Type | Description
--- | --- | ---
*body* | String | AWS SQS response in a function-specific structure that is JSON encoded
*statuscode* | Integer | HTTP status code
*headers* | Table  | See below

The *headers* table consists of the following keys:

Key | Type | Description
--- | --- | ---
*x-amzn-requestid* | String | Amazon request ID
*content-type* | String | Content type, eg. `"text/XML"`
*date* | String | The date and time at which the response was sent
*content-length* | String | The length of the content
*x-amz-crc32* | String | Checksum of the UTF-8 encoded bytes in the HTTP response

# License

The AWSSQS library is licensed under the [MIT License](LICENSE).
