"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (callback) {
  return (0, _functionCache2.default)(callback, {
    useFileCache: false
  });
};

var _functionCache = require("function-cache");

var _functionCache2 = _interopRequireDefault(_functionCache);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;