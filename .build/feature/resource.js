"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (callback) {
  return function (context, name, properties, resource) {
    // console.log context, name, properties
    return callback(context.copy(name, { ...resource,
      Properties: properties
    }));
  };
};

;