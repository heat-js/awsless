"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.playError = exports.playSuccess = exports.playSound = undefined;

var _playSound = require("play-sound");

var _playSound2 = _interopRequireDefault(_playSound);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _options = require("../terminal/options");

var _options2 = _interopRequireDefault(_options);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var player;
player = new _playSound2.default({});

var playSound = exports.playSound = function (file, options) {
  if (options.mute) {
    return;
  }

  return new Promise(function (resolve, reject) {
    return player.play(file, options, function (error) {
      if (error) {
        return reject(error);
      } else {
        return resolve();
      }
    });
  });
};

var playSuccess = exports.playSuccess = function () {
  var file;
  file = _path2.default.join(__dirname, '/success.mp3');
  return playSound(file);
};

var playError = exports.playError = function () {
  var file;
  file = _path2.default.join(__dirname, '/error.mp3');
  return playSound(file);
};