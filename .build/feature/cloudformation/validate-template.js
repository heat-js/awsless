"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function ({
  profile,
  region,
  templateBody,
  templateUrl
}) {
  var cloudFormation, params, result;
  cloudFormation = await (0, _cloudformation2.default)({
    profile,
    region
  });
  params = templateUrl ? {
    TemplateURL: templateUrl
  } : {
    TemplateBody: templateBody
  };
  result = await cloudFormation.validateTemplate(params).promise();
  return result.Capabilities;
};

var _cloudformation = require("../client/cloudformation");

var _cloudformation2 = _interopRequireDefault(_cloudformation);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;