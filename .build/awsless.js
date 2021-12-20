#!/usr/bin/env node
"use strict";

var _commander = require("commander");

var _chalk = require("chalk");

var _chalk2 = _interopRequireDefault(_chalk);

var _deploy = require("./command/deploy");

var _deploy2 = _interopRequireDefault(_deploy);

var _delete = require("./command/delete");

var _delete2 = _interopRequireDefault(_delete);

var _sync = require("./command/sync");

var _sync2 = _interopRequireDefault(_sync);

var _package = require("./package.json");

var _package2 = _interopRequireDefault(_package);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;
var program;
program = new _commander.Command();
program.version(_package2.default.version);
program.name('awsless');
program.usage(_chalk2.default`{blue [command]} {green [options]}`); // .allowExcessArguments()

program.command('deploy').description(_chalk2.default.cyan('deploy the stack to AWS')).option('-c, --capabilities', 'output the stack capabilities that are required').option('-p, --preview', 'preview the stack template').option('-s, --skip-prompt', 'skip confirmation prompt').option('-m, --mute', 'mute sound effects').option('-t, --test', 'run tests before deploying').option('-d, --debug', 'show the full error stack trace').allowUnknownOption().action(_deploy2.default); // .allowExcessArguments()

program.command('delete').description(_chalk2.default.cyan('delete the stack from AWS')).option('-s, --skip-prompt', 'skip confirmation prompt').option('-m, --mute', 'mute sound effects').option('-d, --debug', 'show the full error stack trace').allowUnknownOption().action(_delete2.default); // .allowExcessArguments()

program.command('sync').description(_chalk2.default.cyan('sync to AWS S3')).option('-s, --skip-prompt', 'skip confirmation prompt').option('-m, --mute', 'mute sound effects').option('-d, --debug', 'show the full error stack trace').allowUnknownOption().action(_sync2.default);
program.parse(process.argv);