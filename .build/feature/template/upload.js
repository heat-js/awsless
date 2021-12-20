"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function ({
  profile,
  region,
  stack,
  bucket,
  templateBody
}) {
  var result, s3;

  if (50000 > Buffer.byteLength(templateBody, 'utf8')) {
    return;
  }

  if (!bucket) {
    throw new Error(`Your cloudformation template file size is greater then 50kb.
You need to set a "Config.DeploymentBucket" to handle bigger template files.`);
  }

  s3 = (0, _s2.default)({
    profile,
    region
  });
  result = await s3.putObject({
    Bucket: bucket,
    Key: `${stack}/cloudformation.json`,
    ACL: 'private',
    Body: templateBody,
    StorageClass: 'STANDARD'
  }).promise(); // "s3://#{ bucket }/#{ stack }/cloudformation.json"

  return `https://s3-${region}.amazonaws.com/${bucket}/${stack}/cloudformation.json`;
};

var _s = require("../client/s3");

var _s2 = _interopRequireDefault(_s);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;