"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _awsSdk = require("aws-sdk");

var _awsSdk2 = _interopRequireDefault(_awsSdk);

var _awsParamStore = require("aws-param-store");

var _awsParamStore2 = _interopRequireDefault(_awsParamStore);

var _functionCache = require("../utils/function-cache");

var _functionCache2 = _interopRequireDefault(_functionCache);

var _credentials = require("../client/credentials");

var _credentials2 = _interopRequireDefault(_credentials);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var formatPaths;

formatPaths = function (paths) {
  return paths.map(function (path) {
    if (path[0] === '/') {
      return path;
    }

    return `/${path}`;
  });
};

exports.default = (0, _functionCache2.default)(async function ({
  paths,
  profile,
  region
}) {
  var formattedPath, formattedPaths, i, index, len, parameter, parameters, result;
  formattedPaths = formatPaths(paths);
  result = await _awsParamStore2.default.getParameters(formattedPaths, {
    credentials: (0, _credentials2.default)({
      profile
    }),
    region
  });
  parameters = {};

  for (index = i = 0, len = formattedPaths.length; i < len; index = ++i) {
    formattedPath = formattedPaths[index];
    parameter = result.Parameters.find(function (item) {
      return item.Name === formattedPath;
    });

    if (!parameter) {
      throw new Error(`SSM value not found: ${formattedPath}`);
    }

    parameters[paths[index]] = parameter.Value;
  }

  return parameters;
});