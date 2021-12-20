"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (template, variableResolvers = {}) {
  var entry, errors, i, len, regex, replacement, replacements, variables;
  template = JSON.parse(JSON.stringify(template));
  variables = [];
  findVariables(variableResolvers, variables, template); // console.log 'variables', variables

  replacements = await getVariableReplacements(variableResolvers, variables, template); // console.log 'replacements 1', replacements

  replacements = condenseReplacements(replacements); // console.log 'replacements 2', replacements

  regex = makeRegex();
  errors = []; // console.log variables

  for (i = 0, len = variables.length; i < len; i++) {
    entry = variables[i];

    if (entry.full) {
      replacement = replacements[entry.match];

      if (typeof replacement === 'undefined') {
        errors.push(entry.match);
      } else {
        entry.object[entry.key] = replacement;
      }
    } else {
      entry.object[entry.key] = entry.object[entry.key].replace(regex, function (original, match) {
        if (match !== entry.match) {
          return original;
        }

        replacement = replacements[match];

        if (typeof replacement === 'undefined') {
          errors.push(match);
          return original;
        }

        return replacement;
      });
    }
  } // 		return replacements[ entry.match ]
  // replacement = replacements[ entry.match ]
  // if typeof replacement isnt 'undefined'
  // 	value = value.replace entry.match, replacement
  // 	# console.log entry.object[ entry.key ], value, replacement
  // 	entry.object[ entry.key ] = value
  // else
  // 	errors.push entry.match


  if (errors.length) {
    throw new Error(`Unable to resolve variables: ${errors.join(', ')}`);
  }

  return template;
};

var condenseReplacements, findVariables, getVariableReplacements, makeRegex, variablesItem;

makeRegex = function () {
  return /\$\{ *(([a-z]+)\:([a-z0-9-_\/\.\,:]+)) *\}/gmi;
}; // makeFullRegex = ->
// 	return /^\$\{ *(([a-z]+)\:([a-z0-9-_/\.:]+)) *\}$/gmi


variablesItem = function (variableResolvers, variables, key, value, object) {
  var match, matches, path, regex, results, string, type;

  switch (typeof value) {
    case 'string':
      regex = makeRegex();
      results = [];

      while (matches = regex.exec(value)) {
        [string, match, type, path] = matches;

        if (!variableResolvers[type]) {
          continue;
        } // console.log 'full', string, value


        results.push(variables.push({
          key,
          object,
          match,
          type,
          path,
          full: string === value
        }));
      }

      return results;
      break;
    // regex = makePartialRegex()
    // while matches = regex.exec value
    // 	[ _, match, type, path ] = matches
    // 	if not variableResolvers[type]
    // 		continue
    // 	variables.push { key, object, match, type, path, full: true }

    case 'object':
    case 'array':
      return findVariables(variableResolvers, variables, value);
  }
};

findVariables = function (variableResolvers, variables, object) {
  var i, key, len, results, results1, value;

  switch (typeof object) {
    case 'array':
      results = [];

      for (key = i = 0, len = object.length; i < len; key = ++i) {
        value = object[key];
        results.push(variablesItem(variableResolvers, variables, key, value, object));
      }

      return results;
      break;

    case 'object':
      results1 = [];

      for (key in object) {
        value = object[key];
        results1.push(variablesItem(variableResolvers, variables, key, value, object));
      }

      return results1;
  }
};

condenseReplacements = function (replacements) {
  var limit, original, regex, replaced, replacement;
  regex = makeRegex();
  limit = 10;

  while (limit--) {
    replaced = false;

    for (original in replacements) {
      replacement = replacements[original];

      if (typeof replacement !== 'string') {
        continue;
      }

      replacements[original] = replacement.replace(regex, function (_, match) {
        replaced = true;
        return replacements[match];
      });
    }

    if (!replaced) {
      break;
    }
  }

  return replacements;
}; // limit = 10
// while limit--
// 	replaced = false
// 	for original, replacement of replacements
// 		value = replacements[ replacement ]
// 		if typeof value isnt 'undefined'
// 			replacements[ original ] = value
// 			replaced = true
// 	if not replaced
// 		break
// console.log replacements
// return replacements


getVariableReplacements = async function (variableResolvers, variables, template) {
  var i, index, item, j, len, len1, list, match, matches, paths, replacement, replacements, resolver, type, values;
  replacements = {};

  for (type in variableResolvers) {
    resolver = variableResolvers[type];
    list = variables.filter(function (entry) {
      return type === entry.type;
    });

    if (list.length) {
      matches = {};

      for (i = 0, len = list.length; i < len; i++) {
        item = list[i];
        matches[item.path] = item.match;
      }

      paths = Object.keys(matches);
      matches = Object.values(matches);
      values = await resolver(paths, template);

      for (index = j = 0, len1 = values.length; j < len1; index = ++j) {
        replacement = values[index];
        match = matches[index];
        replacements[match] = replacement;
      }
    }
  }

  return replacements;
};

; // errors = []
// for entry, index in variables
// 	value		= entry.object[ entry.key ]
// 	replacement = replacements[ entry.match ]
// 	if typeof replacement isnt 'undefined'
// 		value = value.replace entry.match, replacement
// 		# console.log entry.object[ entry.key ], value, replacement
// 		entry.object[ entry.key ] = value
// 	else
// 		errors.push entry.match
// if errors.length
// 	throw new Error "Unable to resolve variables: #{ errors.join ', ' }"
// return template