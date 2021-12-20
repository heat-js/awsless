"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _draftlog = require("draftlog");

var TerminalLine;

if (process.env.NODE_ENV === 'test' || process.env.JEST_WORKER_ID) {
  TerminalLine = class TerminalLine {
    update(text) {}

  };
} else {
  (0, _draftlog.into)(console).addLineListener(process.stdin);
  TerminalLine = class TerminalLine {
    constructor() {
      this.draft = console.draft();
    }

    update(text) {
      return this.draft(text);
    }

  };
}

exports.default = TerminalLine;