"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function ({
  profile,
  region,
  distributionId
}) {
  var cloudfront;
  cloudfront = (0, _cloudfront2.default)({
    profile,
    region
  });
  return await cloudfront.createInvalidation({
    DistributionId: distributionId,
    InvalidationBatch: {
      CallerReference: String(Date.now()),
      Paths: {
        Quantity: 1,
        Items: ['/*']
      }
    }
  }).promise();
};

var _cloudfront = require("../client/cloudfront");

var _cloudfront2 = _interopRequireDefault(_cloudfront);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;