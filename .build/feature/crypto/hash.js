"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (alg, content, encoding) {
  var hash;
  hash = _crypto2.default.createHash(alg);
  hash.update(content);
  return hash.digest(encoding);
};

var _crypto = require("crypto");

var _crypto2 = _interopRequireDefault(_crypto);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;