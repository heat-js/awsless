"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _emitter = require("./emitter");

var _emitter2 = _interopRequireDefault(_emitter);

var _reference = require("./reference");

var _reference2 = _interopRequireDefault(_reference);

var _objectPath = require("./feature/object-path");

var _objectPath2 = _interopRequireDefault(_objectPath);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var Context;
exports.default = Context = class Context {
  constructor({
    name: name1,
    singletons = {},
    resource: resource1 = {},
    template = {},
    outputs: outputs1 = {},
    resources: resources1 = {},
    globals = {},
    stacks = [],
    emitter
  }) {
    this.name = name1;
    this.singletons = singletons;
    this.resource = resource1;
    this.template = template;
    this.outputs = outputs1;
    this.resources = resources1;
    this.globals = globals;
    this.stacks = stacks;
    this.emitter = emitter;
    this.refs = {};
  }

  find(type) {
    var Name, ref1, resource, resources;
    resources = [];
    ref1 = this.template;

    for (Name in ref1) {
      resource = ref1[Name];

      if (resource.Type === type) {
        resources.push({
          Name,
          ...resource
        });
      }
    }

    return resources;
  }

  getResources() {
    return this.resources;
  }

  getOutputs() {
    return this.outputs;
  }

  getDefinedStacks() {
    return this.stacks;
  }

  setAttribute(name, attr, value) {
    return this.globals[`attr-${name}-${attr}`] = value;
  } // ref = @ref "attr-#{ name }.#{ attr }"
  // ref.setValue value
  // return @


  getAttribute(name, attr) {
    return this.globals[`attr-${name}-${attr}`];
  }

  addResource(name, resource) {
    return this.resources[name] = resource;
  }

  addOutput(name, output) {
    return this.outputs[name] = output;
  }

  addStack({
    name,
    region,
    profile,
    description,
    resources,
    outputs
  }) {
    return this.stacks.push({
      name,
      region,
      profile,
      description,
      resources,
      outputs
    });
  }

  ref(key) {
    return this.refs[key] || (this.refs[key] = new _reference2.default());
  }

  value(key, value) {
    var ref;
    ref = this.ref(key);
    return ref.setValue(value);
  }

  singleton(key, value) {
    return this.singletons[key] || (this.singletons[key] = value);
  }

  copy(name, resource) {
    return new Context({
      resources: this.resources,
      singletons: this.singletons,
      template: this.template,
      outputs: this.outputs,
      emitter: this.emitter,
      globals: this.globals,
      stacks: this.stacks,
      name,
      resource
    });
  }

  once(event, callback) {
    return this.emitter.once(this.resource.Type, event, callback);
  }

  on(event, callback) {
    return this.emitter.on(event, callback);
  }

  string(paths, defaultValue) {
    return this.property('string', paths, defaultValue);
  }

  number(paths, defaultValue) {
    return this.property('number', paths, defaultValue);
  }

  boolean(paths, defaultValue) {
    return this.property('boolean', paths, defaultValue);
  }

  array(paths, defaultValue) {
    return this.property('array', paths, defaultValue);
  }

  object(paths, defaultValue) {
    return this.property('object', paths, defaultValue);
  }

  any(paths, defaultValue) {
    return this.property(void 0, paths, defaultValue);
  }

  property(type, paths, defaultValue) {
    return (0, _objectPath2.default)({
      template: this.template,
      resource: this.resource,
      properties: this.resource.Properties,
      type,
      paths,
      defaultValue
    });
  }

};