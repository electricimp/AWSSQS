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

#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSQS.lib.nut:1.0.0"


// Configure these parameters see example/README.md for details

const AWS_SQS_ACCESS_KEY_ID = "YOUR_ACCESS_KEY_ID_HERE";
const AWS_SQS_SECRET_ACCESS_KEY = "YOUR_SECRET_ACCESS_KEY_ID_HERE/gFFOFxSMZHAlG2";
const AWS_SQS_URL = "YOUR_SQS_URL_HERE";
const AWS_SQS_REGION = "YOUR_REGION_HERE";

// initialise the class
sqs <- AWSSQS(AWS_SQS_REGION, AWS_SQS_ACCESS_KEY_ID, AWS_SQS_SECRET_ACCESS_KEY);

// finds the ReceiptHandle
function receiptFinder(messageBody) {
    local start = messageBody.find("<ReceiptHandle>");
    local finish = messageBody.find("/ReceiptHandle>");
    local receipt = messageBody.slice(start + 15, finish - 1);
    return receipt;
}


// Send Message Parameters
sendParams <- {
    "QueueUrl": AWS_SQS_URL,
    "MessageBody": "testMessage"
}

// Receive Message Parameters
receiveParams <- {
    "QueueUrl": AWS_SQS_URL
}

// send a message to the queue
sqs.SendMessage(sendParams, function(res) {

    server.log("http response: " + res.statuscode);

    // receive a message from the queue
    sqs.ReceiveMessage(receiveParams, function(res) {

        server.log("http response: " + res.statuscode);
        // do something with res.body. This is where the md5 Message Body is located

        // setup the deletion Parameter
        local deleteParams = {
            "QueueUrl": AWS_SQS_URL,
            "ReceiptHandle": receiptFinder(res.body)
        }

        // Delete the message from the queue
        sqs.DeleteMessage(deleteParams, function(res) {

            server.log("http response: " + res.statuscode);
        });

    });
});
