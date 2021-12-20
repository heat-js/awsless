"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.run = undefined;

var _line = require("./line");

var _line2 = _interopRequireDefault(_line);

var _logSymbols = require("log-symbols");

var _logSymbols2 = _interopRequireDefault(_logSymbols);

var _cliSpinners = require("cli-spinners");

var _cliSpinners2 = _interopRequireDefault(_cliSpinners);

var _chalk = require("chalk");

var _chalk2 = _interopRequireDefault(_chalk);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var Task;

exports.default = Task = function () {
  class Task extends _line2.default {
    constructor() {
      super();
      this.metadata = {};
    }

    warning() {
      return this.icon = _logSymbols2.default.warning;
    }

    success() {
      return this.icon = _logSymbols2.default.success;
    }

    error() {
      return this.icon = _logSymbols2.default.error;
    }

    info() {
      return this.icon = _logSymbols2.default.info;
    }

    done() {
      this.finished = true;
      return this.updateFormattedText();
    }

    setName(name1) {
      this.name = name1;
    }

    setPrefix(prefix) {
      this.prefix = prefix;
    }

    setContent(content) {
      this.content = content;
    }

    addMetadata(key, value) {
      return this.metadata[key] = value;
    }

    updateFormattedText() {
      var icon, metadata, name, pad, text;
      icon = this.icon;

      if (!this.finished) {
        icon = this.spinner.frames[this.index++ % this.spinner.frames.length];
        icon = _chalk2.default`{blue ${icon}}`;
      }

      text = [icon];

      if (this.prefix) {
        text.push(this.prefix);
      }

      if (this.name) {
        pad = 40 - (this.prefix || ' ').length;
        name = this.name.padEnd(pad).substr(0, pad);

        if (this.finished) {
          text.push(_chalk2.default`{yellow ${name}}`);
        } else {
          text.push(_chalk2.default`{dim.yellow ${name}}`);
        }
      } // if @name
      // 	count = (@prefix or '').length + @name.length
      // 	text.push ' '.repeat count


      if (this.content) {
        text.push(this.content);
      }

      metadata = Object.entries(this.metadata);

      if (metadata.length) {
        text.push(`(${metadata.map(function ([key, value]) {
          return _chalk2.default`{dim ${key}:} {blue ${value}}`;
        }).join(_chalk2.default`{dim , }`)})`);
      }

      return this.update(text.join(' '));
    }

  }

  ;
  Task.prototype.icon = _logSymbols2.default.success;
  Task.prototype.index = 0;
  Task.prototype.spinner = _cliSpinners2.default.dots;
  Task.prototype.finished = false;
  return Task;
}.call(undefined);

var run = exports.run = async function (callback) {
  var error, interval, task;
  task = new Task();
  interval = setInterval(function () {
    return task.updateFormattedText();
  }, task.spinner.interval);

  try {
    return await callback(task);
  } catch (error1) {
    error = error1; // task.setContent chalk.red error.message

    task.error();
    throw error;
  } finally {
    clearInterval(interval);
    task.done();
  }
}; // task = (name, callback) ->
// 	if typeof name is 'string'
// 		name = name.padEnd 50
// 	else
// 		callback = name
// 		name = ''
// 	task = new Task
// 	index 	= 0
// 	icon	= symbols.success
// 	length	= spinners.dots.frames.length
// 	line	= new ConsoleLine
// 	content = ''
// 	update 	= ->
// 		spinner = spinners.dots.frames[ index++ % length ]
// 		line.update chalk"{blue #{ spinner }} {yellow #{name}} #{ content }"
// 	interval = setInterval update, spinners.dots.interval
// 	try
// 		await callback (_content) ->
// 			content = _content
// 			update()
// 	catch error
// 		throw error
// 	finally
// 		clearInterval interval
// 		line.update chalk"#{ icon } {dim.yellow #{name}} #{ content }"
// ( ->
// 	promise (task) ->
// 		task.setContent "Validate templates..."
// 		await new Promise (resolve) ->
// 			setTimeout resolve, 4000
// 		# task.setContent "Done Validate templates"
// 	promise (task) ->
// 		task.setPrefix 'Lambda:'
// 		task.setName 'contest__contest-get.zip'
// 		task.setContent "Uploading Lambda..."
// 		await new Promise (resolve) ->
// 			setTimeout resolve, 3000
// 		task.setContent "Upload Lambda Done"
// 		task.addMetadata 'Build', '13.03s'
// 		task.addMetadata 'Size', '248.87 KB'
// 	promise (task) ->
// 		task.setPrefix 'Lambda:'
// 		task.setName 'contest__contest-progress-list.zip'
// 		task.setContent "Uploading Lambda 2"
// 		await new Promise (resolve) ->
// 			setTimeout resolve, 2000
// 		task.setContent "Upload Done"
// 		throw new Error 'Some random error'
// 	promise (task) ->
// 		task.setPrefix 'Lambda:'
// 		task.setName 'contest__contest-get.zip'
// 		task.setContent "Uploading Lambda 3"
// 		await new Promise (resolve) ->
// 			setTimeout resolve, 1000
// 		task.setContent "Upload Done"
// 		task.warning()
// 	promise (task) ->
// 		task.setPrefix 'Lambda:'
// 		task.setName 'contest__contest-get.zip'
// 		task.setContent "Uploading Lambda 3"
// 		await new Promise (resolve) ->
// 			setTimeout resolve, 5000
// 		task.setContent "Upload Done"
// 		task.info()
// 	await new Promise (resolve) ->
// 		setTimeout resolve, 5000
// 	process.exit 0
// )()
// # class ConsoleLineProcess extends ConsoleLine
// # 	@PENDING: 0
// # 	@COMPLETED: 1
// # 	@FAILED: 2
// # 	promise: (text, promise) ->
// # 		@draft text
// # 	done: ->
// line = new ConsoleLineProcess
// index = 0
// setInterval ->
// 	line.update ++index
// , 1000
// var draft = console.draft()
// var elapsed = 1
// setInterval( () => {
//   draft('Elapsed', elapsed++, 'seconds')
// }, 1000)
// console.log('It doesn`t matter')
// console.log('How \n many \n lines \n it uses')