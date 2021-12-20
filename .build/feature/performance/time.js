"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function () {
  var start;
  start = process.hrtime();
  return function () {
    return (0, _prettyHrtime2.default)(process.hrtime(start));
  };
};

var _prettyHrtime = require("pretty-hrtime");

var _prettyHrtime2 = _interopRequireDefault(_prettyHrtime);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;