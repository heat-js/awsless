"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (data) {
  return _jsYaml2.default.load(data, {
    schema
  });
};

var _jsYaml = require("js-yaml");

var _jsYaml2 = _interopRequireDefault(_jsYaml);

var _awsYamlTypes = require("./aws-yaml-types");

var _awsYamlTypes2 = _interopRequireDefault(_awsYamlTypes);

var _customYamlTypes = require("./custom-yaml-types");

var _customYamlTypes2 = _interopRequireDefault(_customYamlTypes);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var schema;
schema = _jsYaml2.default.DEFAULT_SCHEMA.extend([..._awsYamlTypes2.default, ..._customYamlTypes2.default]);
;