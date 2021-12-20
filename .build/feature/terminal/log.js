"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _chalk = require("chalk");

var _chalk2 = _interopRequireDefault(_chalk);

var _promptConfirm = require("prompt-confirm");

var _promptConfirm2 = _interopRequireDefault(_promptConfirm);

var _logSymbols = require("log-symbols");

var _logSymbols2 = _interopRequireDefault(_logSymbols);

var _util = require("util");

var _util2 = _interopRequireDefault(_util);

var _options = require("./options");

var _options2 = _interopRequireDefault(_options);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var log;

log = function (...args) {
  return console.log(...args);
};

exports.default = {
  confirm: function (message, options) {
    var entry;
    entry = new _promptConfirm2.default({
      message,
      default: false,
      ...options
    });
    return entry.run();
  },
  warning: function (message) {
    log(_chalk2.default.yellow(`${_logSymbols2.default.warning} ${message}`));
    return this;
  },
  error: function (message) {
    if (_options2.default.debug) {
      console.error(message);
    } else {
      if (message instanceof Error) {
        ({
          message
        } = message);
      }

      log(_chalk2.default.red(`${_logSymbols2.default.error} ${message}`));
    }

    return this;
  },
  info: function (message) {
    log(_chalk2.default.blue(`${_logSymbols2.default.info} ${message}`));
    return this;
  },
  success: function (message) {
    log(_chalk2.default.green(`${_logSymbols2.default.success} ${message}`));
    return this;
  },
  value: function (key, value) {
    log(_chalk2.default`* {bold ${key}}: {blue ${value}}`);
    return this;
  },
  object: function (value) {
    if (typeof value === 'string') {
      value = JSON.parse(value);
    }

    log(_util2.default.inspect(value, false, null, true));
    return this;
  }
};