"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function ({
  profile,
  region
}) {
  return new _awsSdk2.default.CloudFormation({
    apiVersion: '2010-05-15',
    credentials: (0, _credentials2.default)({
      profile
    }),
    region
  });
};

var _awsSdk = require("aws-sdk");

var _awsSdk2 = _interopRequireDefault(_awsSdk);

var _credentials = require("./credentials");

var _credentials2 = _interopRequireDefault(_credentials);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;