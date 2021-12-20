"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (stacks = []) {
  var options;
  options = {
    borderStyle: 'round',
    borderColor: 'blue',
    dimBorder: true,
    padding: 1,
    margin: 1
  };

  if (stacks.length === 1) {
    single(stacks[0], options);
    return;
  }

  return multi(stacks, options);
};

var _ttyTable = require("tty-table");

var _ttyTable2 = _interopRequireDefault(_ttyTable);

var _chalk = require("chalk");

var _chalk2 = _interopRequireDefault(_chalk);

var _boxen = require("boxen");

var _boxen2 = _interopRequireDefault(_boxen);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var multi, single;
;

single = function (stack, options) {
  var rows, table;
  rows = [[Object.keys(stack).map(function (name) {
    return _chalk2.default`{yellow ${name}:}`;
  }).join('\n'), Object.values(stack).join('\n')]];
  table = (0, _ttyTable2.default)([], rows, {
    showHeader: false,
    headerAlign: 'left',
    align: 'left',
    marginTop: 0,
    marginLeft: 0,
    // paddingTop: 0
    paddingLeft: 1,
    borderStyle: 'none',
    compact: true
  });
  return console.log((0, _boxen2.default)(_chalk2.default`{blue.bold  Stack Information}
${table.render()}`, { ...options,
    padding: {
      top: 1,
      left: 2,
      right: 2
    }
  }));
};

multi = function (stacks, options) {
  var headers, rows, table;
  headers = [{}, ...stacks.map(function (_, index) {
    return {
      value: _chalk2.default`{blue.bold Stack ${index + 1}.}`,
      align: 'left'
    };
  })];
  rows = [[Object.keys(stacks[0]).map(function (name) {
    return _chalk2.default`{yellow ${name}:}`;
  }).join('\n'), ...stacks.map(function (stack) {
    return Object.values(stack).join('\n');
  })]];
  table = (0, _ttyTable2.default)(headers, rows, {
    headerAlign: 'left',
    marginTop: 0,
    marginLeft: 0,
    paddingTop: 1,
    paddingLeft: 1,
    borderStyle: 'none',
    compact: true
  });
  return console.log((0, _boxen2.default)(table.render(), { ...options,
    padding: {
      left: 2,
      right: 2
    }
  }));
};