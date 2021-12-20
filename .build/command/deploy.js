"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (options) {
  var capabilities, cloudformationDir, context, error, file, i, index, j, json, k, len, len1, len2, list, stack, stacks;

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
      if (!(await _log2.default.confirm(_chalk2.default`Are u sure you want to {green deploy} the stack?`))) {
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
    // Run events before stack update
    // 1

    await context.emitter.emit('validate-resource'); // 2

    await context.emitter.emitParallel('prepare-resource'); // 3

    await context.emitter.emit('before-stringify-template'); // -----------------------------------------------------
    // Convert the template to JSON
    // Split the stacks again to make sure we have all the
    // template changes committed

    stacks = (0, _split2.default)(context);

    for (i = 0, len = stacks.length; i < len; i++) {
      stack = stacks[i];
      stack.templateBody = (0, _stringify2.default)(stack.templateBody, context.globals);
    } // -----------------------------------------------------
    // Save a copy of the stack templates in the build
    // folder


    for (j = 0, len1 = stacks.length; j < len1; j++) {
      stack = stacks[j];
      file = _path2.default.join(cloudformationDir, `${stack.stack}.${stack.region}.json`);
      json = JSON.parse(stack.templateBody);
      await (0, _writeFile2.default)(file, (0, _jsonFormat2.default)(json));
    } // -----------------------------------------------------
    // Log the template to the console


    if (options.preview) {
      for (index = k = 0, len2 = stacks.length; k < len2; index = ++k) {
        stack = stacks[index];

        _log2.default.info(`Stack ${index}:`);

        _log2.default.object(stack.template);
      }
    } // -----------------------------------------------------
    // Upload Stack


    await context.emitter.emit('before-upload-stack');
    await (0, _task.run)(function (task) {
      task.setContent('Uploading templates...');
      return Promise.all(stacks.map(async function (stack) {
        return stack.templateUrl = await (0, _upload2.default)(stack);
      }));
    }); // -----------------------------------------------------
    // Validate Templates & get the stack capabilities

    await context.emitter.emit('before-validating-template');
    capabilities = await (0, _task.run)(function (task) {
      task.setContent('Validate templates...');
      return Promise.all(stacks.map(async function (stack) {
        return stack.capabilities = await (0, _validateTemplate2.default)(stack);
      }));
    }); // -----------------------------------------------------
    // Log the stack capabilities

    if (options.capabilities) {
      list = capabilities.flat();

      if (list.length > 0) {
        _log2.default.info(_chalk2.default`{white The stack is using the following capabilities:} ${list.join(', ')}`);
      } else {
        _log2.default.info(_chalk2.default.white('The stack is using no special capabilities'));
      }
    } // -----------------------------------------------------
    // Deploying stacks


    await context.emitter.emit('before-deploying-stack'); // await run (task) ->
    // task.setContent "Deploying stack..."

    await Promise.all(stacks.map(function (stack) {
      return (0, _deployStack2.default)({
        stack: stack.stack,
        profile: stack.profile,
        region: stack.region,
        templateUrl: stack.templateUrl,
        templateBody: stack.templateBody,
        capabilities: stack.capabilities
      });
    })); // task.setContent chalk.underline.green "Deploying stack..."
    // success "Stack has successfully been deployed."
    // -----------------------------------------------------
    // Run events after stack update

    await context.emitter.emit('after-deploying-stack'); // -----------------------------------------------------
    // play success sound
    // await playSuccess()

    (0, _say2.default)(`The ${stacks[0].stack} service has been deployed.`);
  } catch (error1) {
    error = error1;

    _log2.default.error(error); // -----------------------------------------------------
    // play error sound
    // await playError()


    (0, _say2.default)(`An error occurred deploying the ${stacks[0].stack} service.`);
  }

  return process.exit(0);
};

var _load = require("../feature/template/load");

var _load2 = _interopRequireDefault(_load);

var _resolveResources = require("../feature/template/resolve-resources");

var _resolveResources2 = _interopRequireDefault(_resolveResources);

var _resolveVariables = require("../feature/template/resolve-variables");

var _resolveVariables2 = _interopRequireDefault(_resolveVariables);

var _stringify = require("../feature/template/stringify");

var _stringify2 = _interopRequireDefault(_stringify);

var _deployStack = require("../feature/cloudformation/deploy-stack");

var _deployStack2 = _interopRequireDefault(_deployStack);

var _validateTemplate = require("../feature/cloudformation/validate-template");

var _validateTemplate2 = _interopRequireDefault(_validateTemplate);

var _split = require("../feature/template/split");

var _split2 = _interopRequireDefault(_split);

var _upload = require("../feature/template/upload");

var _upload2 = _interopRequireDefault(_upload);

var _writeFile = require("../feature/fs/write-file");

var _writeFile2 = _interopRequireDefault(_writeFile);

var _removeDirectory = require("../feature/fs/remove-directory");

var _removeDirectory2 = _interopRequireDefault(_removeDirectory);

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

var _jsonFormat = require("json-format");

var _jsonFormat2 = _interopRequireDefault(_jsonFormat);

var _config = require("../config");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;