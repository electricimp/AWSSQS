// MIT License
//
// Copyright 2017 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.


// Please Enter your AWS keys, region and SQS URL

@include "github:electricimp/AWSRequestV4/AWSRequestV4.class.nut"
@include "AWSSQS.agent.lib.nut"

const AWS_TEST_ACCESS_KEY_ID = "@{SQS_ACCESS_KEY_ID}";
const AWS_TEST_SECRET_ACCESS_KEY = "@{SQS_SECRET_ACCESS_KEY}";
const AWS_TEST_SQS_URL = "@{SQS_URL}";
const AWS_TEST_REGION = "@{SQS_REGION}";

const AWS_TEST_MESSAGE = "testMessage";

// invalid information used to check tests
const AWS_TEST_INVALID_ACCESS_KEY_ID = "AAAAAAAAAAAAAAAAAAAAA";
const AWS_TEST_INVALID_RECEIPT_HANDLE = "ASFAEDFAWEFQAWEQWFDAF";

// http response codes
const AWS_TEST_HTTP_RESPONSE_SUCCESS = 200;
const AWS_TEST_HTTP_RESPONSE_FORBIDDEN = 403;
const AWS_TEST_HTTP_RESPONSE_NOT_FOUND = 404;
const AWS_TEST_HTTP_RESPONSE_BAD_REQUEST = 400;

class AgentTestCase extends ImpTestCase {

    _sqs = null;

    // setUP initialises the class
    function setUp() {
        _sqs = AWSSQS(AWS_TEST_REGION, AWS_TEST_ACCESS_KEY_ID, AWS_TEST_SECRET_ACCESS_KEY);
    }

    // testing successfully sending a message. Checks against http ok response
    function testSendMessage() {
        // message params
        local sendParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "MessageBody": AWS_TEST_MESSAGE
        };

        return Promise(function(resolve, reject) {
            _sqs.action(AWSSQS_ACTION_SEND_MESSAGE, sendParams, function(res) {
                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual status code " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // testing failing to send a message due to an invalid aws access key. Check against a http forbidden response
    function testInvalidKey() {
        local sqs = AWSSQS(AWS_TEST_REGION, AWS_TEST_INVALID_ACCESS_KEY_ID, AWS_TEST_SECRET_ACCESS_KEY);
        // message params
        local sendParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "MessageBody": AWS_TEST_MESSAGE
        };

        return Promise(function(resolve, reject) {
            sqs.action(AWSSQS_ACTION_SEND_MESSAGE, sendParams, function(res) {
                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_FORBIDDEN, "Actual status code " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // first send a message to be received
    // test successfully receiving a message. Checking against a successful http response.
    // checks that the message text is in the response packet
    function testReceiveMessage() {
        local receiveParams = {
                "QueueUrl": AWS_TEST_SQS_URL
        };
        // message params
        local sendParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "MessageBody": AWS_TEST_MESSAGE
        };

        return Promise(function(resolve, reject) {
            _sqs.action(AWSSQS_ACTION_SEND_MESSAGE, sendParams, function(res) {
                imp.wakeup(2, function() {
                    _sqs.action(AWSSQS_ACTION_RECEIVE_MESSAGE, receiveParams, function(res) {
                        try {
                            this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual status code " + res.statuscode);
                            this.assertTrue(res.body.find(AWS_TEST_MESSAGE) != null);
                            resolve();
                        } catch (e) {
                            reject(e);
                        }
                    }.bindenv(this));
                }.bindenv(this))
            }.bindenv(this));
        }.bindenv(this));
    }

    // test successfully deleting a message
    // send a message that we will delete
    // first need to receive a message to get ReceiptHandle then you can delete it
    // check that the receipt no longer listed
    function testDeleteMessage() {
        // finds the receipt handle string in the body string.
        local receiptFinder = function(messageBody) {
            local start = messageBody.find("<ReceiptHandle>");
            local finish = messageBody.find("/ReceiptHandle>");
            local receipt = messageBody.slice((start + 15), (finish - 1));
            return receipt;
        };
        local receiveParams = {
            "QueueUrl": AWS_TEST_SQS_URL
        };
        // message params
        local sendParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "MessageBody": AWS_TEST_MESSAGE
        };

        return Promise(function(resolve, reject) {
            _sqs.action(AWSSQS_ACTION_SEND_MESSAGE, sendParams, function(res) {
                _sqs.action(AWSSQS_ACTION_RECEIVE_MESSAGE, receiveParams, function(res) {
                    local receipt = receiptFinder(res.body);
                    local deleteParams = {
                        "QueueUrl": AWS_TEST_SQS_URL,
                        "ReceiptHandle": receipt
                    }
                    _sqs.action(AWSSQS_ACTION_DELETE_MESSAGE, deleteParams, function(res) {
                        try {
                            this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual status code " + res.statuscode);
                            imp.wakeup(2, function() {
                                _sqs.action(AWSSQS_ACTION_RECEIVE_MESSAGE, receiveParams, function(res) {
                                    try {
                                        this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual status code " + res.statuscode);
                                        this.assertTrue(res.body.find(receipt) == null);
                                        resolve();
                                    } catch (e) {
                                        reject(e);
                                    }
                                }.bindenv(this));
                            }.bindenv(this))
                        } catch (e) {
                            reject(e);
                        }
                    }.bindenv(this));
                }.bindenv(this));

            }.bindenv(this));
        }.bindenv(this));
    }

    // using an invalid ReceiptHandle to fail to delete a message. Check against http response code
    function testFailDeleteMessage() {
        local deleteParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "ReceiptHandle": AWS_TEST_INVALID_RECEIPT_HANDLE
        };

        return Promise(function(resolve, reject) {
            _sqs.action(AWSSQS_ACTION_DELETE_MESSAGE, deleteParams, function(res) {
                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_NOT_FOUND, "Actual status code " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // test a successful batch transmission. Validate against the http response
    function testSendBatchMessages() {
        // parameters for sending multiple messages
        local messageBatchParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "SendMessageBatchRequestEntry.1.Id": "m1",
            "SendMessageBatchRequestEntry.1.MessageBody": "testMessage1",
            "SendMessageBatchRequestEntry.2.Id": "m2",
            "SendMessageBatchRequestEntry.2.MessageBody": "testMessage2",
        };

        return Promise(function(resolve, reject) {
            _sqs.action(AWSSQS_ACTION_SEND_MESSAGE_BATCH, messageBatchParams, function(res) {
                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual status code " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // test a failure batch transmission. When id's are not unique should receive a 400 response
    function testFailSendBatchMessages() {
        // note duplicate id's in parameters
        local messageBatchParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "SendMessageBatchRequestEntry.1.Id": "m1",
            "SendMessageBatchRequestEntry.1.MessageBody": "testMessage1",
            "SendMessageBatchRequestEntry.2.Id": "m1",
            "SendMessageBatchRequestEntry.2.MessageBody": "testMessage2",
        };

        return Promise(function(resolve, reject) {
            _sqs.action(AWSSQS_ACTION_SEND_MESSAGE_BATCH, messageBatchParams, function(res) {
                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual status code " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // test successfully deleting a batch of messages. Validate against the http response
    function testDeleteMessageBatch() {

        // parameters for multiple messages to be sent
        local messageBatchParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "SendMessageBatchRequestEntry.1.Id": "m1",
            "SendMessageBatchRequestEntry.1.MessageBody": "testMessage1",
            "SendMessageBatchRequestEntry.2.Id": "m2",
            "SendMessageBatchRequestEntry.2.MessageBody": "testMessage2",
        };
        // finds the receipt handle string in the body string.
        local receiptFinder = function(messageBody) {
            local start = messageBody.find("<ReceiptHandle>");
            local finish = messageBody.find("/ReceiptHandle>");
            local receipt = messageBody.slice((start + 15), (finish - 1));
            return receipt;
        };
        // reception parameters to recieve messages
        local receiveParams = {
            "QueueUrl": AWS_TEST_SQS_URL
        };

        return Promise(function(resolve, reject) {
            // send multiple messages
            _sqs.action(AWSSQS_ACTION_SEND_MESSAGE_BATCH, messageBatchParams, function(res) {
                // receive multiple messages
                _sqs.action(AWSSQS_ACTION_RECEIVE_MESSAGE, receiveParams, function(res) {
                    // get the receipt handle and set up the deletion parameters
                    local receipt = receiptFinder(res.body);
                    local deleteParams = {
                        "QueueUrl": AWS_TEST_SQS_URL,
                        "DeleteMessageBatchRequestEntry.1.Id": "m1"
                        "DeleteMessageBatchRequestEntry.1.ReceiptHandle": receipt,
                    }
                    _sqs.action(AWSSQS_ACTION_DELETE_MESSAGE_BATCH, deleteParams, function(res) {
                        try {
                            this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual status code " + res.statuscode);
                            resolve();
                        } catch (e) {
                            reject(e);
                        }
                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));
    }

    // test for an unsuccessful deletion of a batch. When deletion params has no details the
    // http should respond with a bad request
    function testFailDeleteMessageBatch() {

        // parameters for multiple messages to be sent
        local messageBatchParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "SendMessageBatchRequestEntry.1.Id": "m1",
            "SendMessageBatchRequestEntry.1.MessageBody": "testMessage1",
            "SendMessageBatchRequestEntry.2.Id": "m2",
            "SendMessageBatchRequestEntry.2.MessageBody": "testMessage2",
        };
        // finds the receipt handle string in the body string.
        local receiptFinder = function(messageBody) {
            local start = messageBody.find("<ReceiptHandle>");
            local finish = messageBody.find("/ReceiptHandle>");
            local receipt = messageBody.slice((start + 15), (finish - 1));
            return receipt;
        };
        // reception parameters to receive messages
        local receiveParams = {
            "QueueUrl": AWS_TEST_SQS_URL
        };

        return Promise(function(resolve, reject) {
            // send multiple messages
            _sqs.action(AWSSQS_ACTION_SEND_MESSAGE_BATCH, messageBatchParams, function(res) {
                // receive multiple messages
                _sqs.action(AWSSQS_ACTION_RECEIVE_MESSAGE, receiveParams, function(res) {
                    // get the receipt handle and set up the deletion parameters
                    local receipt = receiptFinder(res.body);
                    local deleteParams = {
                        "QueueUrl": AWS_TEST_SQS_URL,
                    }
                    _sqs.action(AWSSQS_ACTION_DELETE_MESSAGE_BATCH, deleteParams, function(res) {
                        try {
                            this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual status code " + res.statuscode);
                            resolve();
                        } catch (e) {
                            reject(e);
                        }
                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));
    }
}
