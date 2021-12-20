"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (message, name = 'Daniel', speed = 1) {
  if (_options2.default.mute) {
    return;
  }

  return new Promise(function (resolve, reject) {
    return _say2.default.speak(message, name, speed, function (error) {
      if (error) {
        return reject(error);
      } else {
        return resolve();
      }
    });
  });
};

var _say = require("say");

var _say2 = _interopRequireDefault(_say);

var _options = require("../terminal/options");

var _options2 = _interopRequireDefault(_options);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;