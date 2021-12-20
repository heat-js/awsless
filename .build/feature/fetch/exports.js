"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _functionCache = require("../utils/function-cache");

var _functionCache2 = _interopRequireDefault(_functionCache);

var _cloudformation = require("../client/cloudformation");

var _cloudformation2 = _interopRequireDefault(_cloudformation);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

exports.default = (0, _functionCache2.default)(async function ({
  profile,
  region
}) {
  var cloudFormation, i, item, len, list, params, ref, result;
  cloudFormation = (0, _cloudformation2.default)({
    profile,
    region
  });
  list = {};
  params = {};

  while (true) {
    result = await cloudFormation.listExports(params).promise();
    ref = result.Exports;

    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      list[item.Name] = item.Value;
    }

    if (result.NextToken) {
      params.NextToken = result.NextToken;
    } else {
      break;
    }
  }

  return list;
});