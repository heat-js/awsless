"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (options) {
  var cloudformationDir, context, error, stacks;

  try {
    context = await (0, _task.run)(async function (task) {
      var template; // -----------------------------------------------------
      // Load the template files

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
      if (!(await _log2.default.confirm(_chalk2.default`Are u sure you want to {red delete} the stack?`))) {
        _log2.default.warning('Cancelled.');

        return;
      }
    } // -----------------------------------------------------
    // Clean up previous build files


    cloudformationDir = _path2.default.join(process.cwd(), '.awsless', 'cloudformation');
    await (0, _task.run)(async function (task) {
      task.setContent('Cleaning up...');
      return await Promise.all([(0, _removeDirectory2.default)(cloudformationDir), context.emitter.emit('cleanup')]);
    }); // -----------------------------------------------------
    // Run events before stack delete

    await context.emitter.emit('before-deleting-stack'); // -----------------------------------------------------
    // Split the stacks again to make sure we have all the
    // template changes committed

    stacks = (0, _split2.default)(context); // -----------------------------------------------------
    // Deleting stacks

    await Promise.all(stacks.map(function (stack) {
      return (0, _deleteStack2.default)({
        stack: stack.stack,
        profile: stack.profile,
        region: stack.region
      });
    })); // -----------------------------------------------------
    // Run events after stack delete

    await context.emitter.emit('after-deleting-stack'); // -----------------------------------------------------
    // play success sound
    // await playSuccess()

    (0, _say2.default)(`The ${stacks[0].stack} service has been deleted.`);
  } catch (error1) {
    error = error1;

    _log2.default.error(error); // -----------------------------------------------------
    // play error sound
    // await playError()


    (0, _say2.default)(`An error occurred deleting the ${stacks[0].stack} service.`);
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

var _deleteStack = require("../feature/cloudformation/delete-stack");

var _deleteStack2 = _interopRequireDefault(_deleteStack);

var _removeDirectory = require("../feature/fs/remove-directory");

var _removeDirectory2 = _interopRequireDefault(_removeDirectory);

var _logStacks = require("../feature/terminal/log-stacks");

var _logStacks2 = _interopRequireDefault(_logStacks);

var _log = require("../feature/terminal/log");

var _log2 = _interopRequireDefault(_log);

var _task = require("../feature/terminal/task");

var _say = require("../feature/sound/say");

var _say2 = _interopRequireDefault(_say);

var _chalk = require("chalk");

var _chalk2 = _interopRequireDefault(_chalk);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _config = require("../config");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;