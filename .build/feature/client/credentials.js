"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function ({
  profile
}) {
  return new _awsSdk2.default.SharedIniFileCredentials({
    profile
  });
};

var _awsSdk = require("aws-sdk");

var _awsSdk2 = _interopRequireDefault(_awsSdk);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

; // chain = new AWS.CredentialProviderChain()
// if profile
// 	chain.providers.push new AWS.SharedIniFileCredentials { profile }
// return chain