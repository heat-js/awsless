"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
var Reference;
exports.default = Reference = class Reference {
  setValue(value) {
    this.value = value;
  }

  toJSON() {
    return this.value;
  }

};