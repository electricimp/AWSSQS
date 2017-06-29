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

class AWSSQS {

    static VERSION = "1.0.0";
    static SERVICE = "sqs";
    static TARGET_PREFIX = "SQS_20121105";

    _awsRequest = null;

    // 	Parameters:
    //	 region				AWS region
    //   accessKeyId		AWS access key Id
    //   secretAccessKey    AWS secret access key
    constructor(region, accessKeyId, secretAccessKey) {
        if ("AWSRequestV4" in getroottable()) {
            _awsRequest = AWSRequestV4(SERVICE, region, accessKeyId, secretAccessKey);
        } else {
            throw ("This class requires AWSRequestV4 - please make sure it is loaded.");
        }
    }

    //	Deletes the specified message from the specified queue
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //						from aws
    function DeleteMessage(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "DeleteMessage",
            "Version": "2012-11-05"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    //	Deletes up to ten messages from the specified queue
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //						from aws
    function DeleteMessageBatch(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "DeleteMessageBatch",
            "Version": "2012-11-05"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    //	Retrieves one or more messages (up to 10), from the specified queue
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //						from aws
    function ReceiveMessage(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "ReceiveMessage",
            "Version": "2012-11-05"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    //	Delivers a message to the specified queue
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //						from aws
    function SendMessage(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "SendMessage",
            "Version": "2012-11-05"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    //	Delivers up to ten messages to the specified queue
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //						from aws
    function SendMessageBatch(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "SendMessageBatch",
            "Version": "2012-11-05"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

}
