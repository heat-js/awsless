"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function ({
  profile,
  region,
  stack
}) {
  var cloudFormation, error, ref, result;
  cloudFormation = (0, _cloudformation2.default)({
    profile,
    region
  });

  try {
    result = await cloudFormation.describeStacks({
      StackName: stack
    }).promise();
  } catch (error1) {
    error = error1;

    if (error.code === 'ValidationError' && error.message.includes('does not exist')) {
      return false;
    }

    throw error;
  }

  return (ref = result.Stacks[0]) != null ? ref.StackStatus : void 0;
};

var _cloudformation = require("../client/cloudformation");

var _cloudformation2 = _interopRequireDefault(_cloudformation);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;