"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (options) {
  var context, error, stacks;

  try {
    // -----------------------------------------------------
    // Run tests
    if (options.test) {
      if (!(await (0, _run2.default)())) {
        throw new Error('Tests failed');
      }
    } // -----------------------------------------------------
    // Load the template files


    context = await (0, _task.run)(async function (task) {
      var template;
      task.setContent("Loading templates...");
      template = await (0, _load2.default)(_path2.default.join(process.cwd(), 'aws')); // -----------------------------------------------------
      // Resolve the local variable resolvers

      task.setContent("Resolve variables...");
      template = await (0, _resolveVariables2.default)(template, _config.localResolvers); // -----------------------------------------------------
      // Resolve the remote variable resolvers

      template = await (0, _resolveVariables2.default)(template, _config.remoteResolvers); // -----------------------------------------------------
      // Resolve the logical resolvers

      template = await (0, _resolveVariables2.default)(template, _config.logicalResolvers); // -----------------------------------------------------
      // Parse our custom resources

      task.setContent("Parsing resources...");
      context = await (0, _resolveResources2.default)(template, _config.resources); // task.setContent "Parsing resources"

      return context;
    }); // -----------------------------------------------------
    // Split the stack into multiple stacks if needed

    stacks = (0, _split2.default)(context); // -----------------------------------------------------
    // Log stack(s) information

    (0, _logStacks2.default)(stacks.map(function (stack) {
      return {
        Stack: stack.stack,
        Region: stack.region,
        Profile: stack.profile
      };
    })); // -----------------------------------------------------
    // Show confirm prompt

    if (!options.skipPrompt) {
      if (!(await _log2.default.confirm(_chalk2.default`Are u sure you want to {green sync}?`))) {
        _log2.default.warning('Cancelled.');

        return;
      }
    } // -----------------------------------------------------
    // Run events
    // 1


    await context.emitter.emit('validate-resource'); // 2

    await context.emitter.emit('before-sync'); // 3

    await context.emitter.emit('sync'); // 4

    await context.emitter.emit('after-sync'); // -----------------------------------------------------
    // play success sound
    // await playSuccess()

    (0, _say2.default)(`The ${stacks[0].stack} service has been synced.`);
  } catch (error1) {
    error = error1;

    _log2.default.error(error); // -----------------------------------------------------
    // play error sound
    // await playError()


    (0, _say2.default)(`An error occurred syncing the ${stacks[0].stack} service.`);
  }

  return process.exit(0);
};

var _load = require("../feature/template/load");

var _load2 = _interopRequireDefault(_load);

var _resolveResources = require("../feature/template/resolve-resources");

var _resolveResources2 = _interopRequireDefault(_resolveResources);

var _resolveVariables = require("../feature/template/resolve-variables");

var _resolveVariables2 = _interopRequireDefault(_resolveVariables);

var _split = require("../feature/template/split");

var _split2 = _interopRequireDefault(_split);

var _logStacks = require("../feature/terminal/log-stacks");

var _logStacks2 = _interopRequireDefault(_logStacks);

var _task = require("../feature/terminal/task");

var _log = require("../feature/terminal/log");

var _log2 = _interopRequireDefault(_log);

var _run = require("../feature/test/run");

var _run2 = _interopRequireDefault(_run);

var _say = require("../feature/sound/say");

var _say2 = _interopRequireDefault(_say);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _chalk = require("chalk");

var _chalk2 = _interopRequireDefault(_chalk);

var _config = require("../config");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;