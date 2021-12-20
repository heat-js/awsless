"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (...args) {
  return (0, _hash2.default)('sha1', JSON.stringify(args), 'hex').substr(0, 16);
};

var _hash = require("./hash");

var _hash2 = _interopRequireDefault(_hash);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;