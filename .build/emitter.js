"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
var Emitter;
exports.default = Emitter = class Emitter {
  constructor() {
    this.events = {};
    this.keys = [];
  }

  on(eventName, callback) {
    var list;

    if (Array.isArray(eventName)) {
      return eventName.map(name => {
        return this.on(name, callback);
      });
    }

    list = this.events[eventName];

    if (!list) {
      list = this.events[eventName] = [];
    }

    return list.push(callback);
  }

  once(key, eventName, callback) {
    // if Array.isArray eventName
    // 	return eventName.map (name) =>
    // 		@on name, callback
    key = `${key}-${eventName}`;

    if (this.keys.includes(key)) {
      return;
    }

    this.keys.push(key);
    return this.on(eventName, callback);
  }

  async emit(eventName, ...props) {
    var callback, i, len, list, results;
    list = this.events[eventName];

    if (!list) {
      return;
    }

    results = [];

    for (i = 0, len = list.length; i < len; i++) {
      callback = list[i];
      results.push(await callback.apply(null, props));
    }

    return results;
  }

  emitParallel(eventName, ...props) {
    var list;
    list = this.events[eventName];

    if (!list) {
      return;
    }

    return Promise.all(list.map(function (callback) {
      return callback.apply(null, props);
    }));
  }

};