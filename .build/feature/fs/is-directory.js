"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (path) {
  var error, stats;

  try {
    stats = await _fs2.default.promises.stat(path);
  } catch (error1) {
    error = error1;

    if (error.message.includes('no such file or directory')) {
      return false;
    }

    throw error;
  }

  return stats.isDirectory();
};

var _fs = require("fs");

var _fs2 = _interopRequireDefault(_fs);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;