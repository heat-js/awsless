"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _jsYaml = require("js-yaml");

var _jsYaml2 = _interopRequireDefault(_jsYaml);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var customType;

customType = function (name, kind, sep) {
  return new _jsYaml2.default.Type(`!${name}`, {
    kind,
    instanceOf: String,
    construct: function (data) {
      switch (kind) {
        case 'sequence':
          return `\${ ${name}:${data.join(sep)} }`;

        default:
          return `\${ ${name}:${data} }`;
      }
    }
  });
};

exports.default = [customType('when', 'sequence', ','), customType('attr', 'sequence', '.'), customType('attr', 'scalar'), customType('cf', 'sequence', ':'), customType('cf', 'scalar'), customType('var', 'sequence', '.'), customType('var', 'scalar'), customType('ssm', 'sequence', ':'), customType('ssm', 'scalar'), customType('opt', 'scalar'), customType('env', 'scalar')];