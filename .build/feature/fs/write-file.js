"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (file, data) {
  await (0, _mkdirp2.default)(_path2.default.dirname(file));
  return await _fs2.default.promises.writeFile(file, data);
};

var _mkdirp = require("mkdirp");

var _mkdirp2 = _interopRequireDefault(_mkdirp);

var _fs = require("fs");

var _fs2 = _interopRequireDefault(_fs);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;