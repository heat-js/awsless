"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function ({
  profile,
  region,
  bucket,
  key
}) {
  var result, s3;
  s3 = (0, _s2.default)({
    profile,
    region
  });
  return result = await s3.deleteObject({
    Bucket: bucket,
    Key: key
  }).promise();
};

var _s = require("../client/s3");

var _s2 = _interopRequireDefault(_s);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;