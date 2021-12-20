"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (callback) {
  return queue.add(callback);
};

var _os = require("os");

var _os2 = _interopRequireDefault(_os);

var _promiseQueue = require("promise-queue");

var _promiseQueue2 = _interopRequireDefault(_promiseQueue);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var concurrency, queue;
concurrency = Math.round(_os2.default.cpus().length / 2);
concurrency = Math.max(1, concurrency);
queue = new _promiseQueue2.default(concurrency);
;