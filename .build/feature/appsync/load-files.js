"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (sourceFiles, mappingTemplates) {
  var definitions, error, files, i, len, resolver, resolverFiles, resolvers, root, schema, schemaFiles, templateFiles, templates, types;

  try {
    files = await (0, _listFilesRecursive2.default)(sourceFiles);
  } catch (error1) {
    error = error1;

    if (error.code === 'ENOENT') {
      throw new Error(`Appsync template directory doesn't exist '${directory}'`);
    }

    throw error;
  } // console.log files


  schemaFiles = filterByExtensions(files, ['.gql', '.graphql']);
  resolverFiles = filterByExtensions(files, ['.yml', '.yaml']);
  templateFiles = filterByExtensions(files, ['.vtl']);
  types = await Promise.all(schemaFiles.map(function (file) {
    return _fs2.default.promises.readFile(file, {
      encoding: 'utf8'
    });
  })); // console.log types

  schema = (0, _merge.mergeTypeDefs)(types, {
    useSchemaDefinition: true,
    forceSchemaDefinition: true,
    throwOnConflict: true,
    commentDescriptions: true,
    reverseDirectives: true
  });
  ({
    definitions
  } = (0, _language.parse)(schema)); // console.log 'schema', schema
  // # console.log 'definitions', definitions
  // console.log 'fields', definitions[2]
  // console.log 'fields', definitions[2].fields
  // console.log mappingTemplates, sourceFiles

  root = _path2.default.normalize(mappingTemplates || sourceFiles); // console.log root

  templates = {};
  await Promise.all(templateFiles.map(async function (file) {
    var template;
    template = await _fs2.default.promises.readFile(file, {
      encoding: 'utf8'
    });
    return templates[file.replace(root, '')] = template;
  })); // console.log 'templates', templates

  resolvers = [];
  await Promise.all(resolverFiles.map(async function (file) {
    var i, item, items, len, results;
    items = await _fs2.default.promises.readFile(file, {
      encoding: 'utf8'
    });
    items = (0, _parse2.default)(items);
    results = [];

    for (i = 0, len = items.length; i < len; i++) {
      item = items[i];
      results.push(resolvers.push({
        id: [(0, _capitalize2.default)(item.Type), (0, _capitalize2.default)(item.Field)].join(''),
        type: item.Type,
        field: item.Field,
        request: getTemplate(templates, item.Request),
        response: getTemplate(templates, item.Response),
        dataSource: getDataSource(item)
      }));
    }

    return results;
  }));

  for (i = 0, len = resolvers.length; i < len; i++) {
    resolver = resolvers[i];
    assertValidateResolver(definitions, resolver);
  } // console.log 'resolvers', resolvers


  return {
    schema,
    resolvers
  };
};

var _merge = require("@graphql-tools/merge");

var _language = require("graphql/language");

var _listFilesRecursive = require("../fs/list-files-recursive");

var _listFilesRecursive2 = _interopRequireDefault(_listFilesRecursive);

var _parse = require("../template/parse");

var _parse2 = _interopRequireDefault(_parse);

var _checksum = require("../crypto/checksum");

var _checksum2 = _interopRequireDefault(_checksum);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _fs = require("fs");

var _fs2 = _interopRequireDefault(_fs);

var _capitalize = require("capitalize");

var _capitalize2 = _interopRequireDefault(_capitalize);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var assertValidateResolver, filterByExtensions, getDataSource, getTemplate;

filterByExtensions = function (files, extensions) {
  return files.filter(function (file) {
    var extension;
    extension = _path2.default.extname(file).toLowerCase();
    return extensions.includes(extension);
  });
};

assertValidateResolver = function (definitions, item) {
  var definition, field, i, j, len, len1, ref, ref1, ref2;

  for (i = 0, len = definitions.length; i < len; i++) {
    definition = definitions[i];

    if (item.type === ((ref = definition.name) != null ? ref.value : void 0)) {
      ref1 = definition.fields;

      for (j = 0, len1 = ref1.length; j < len1; j++) {
        field = ref1[j];

        if (item.field === ((ref2 = field.name) != null ? ref2.value : void 0)) {
          return true;
        }
      }
    }
  }

  throw new Error(`No graphql definition found for type '${item.type}' with field '${item.field}'`);
};

getTemplate = function (templates, key) {
  var template;

  if (typeof key !== 'string') {
    throw new Error(`Appsync mapping template not found: ${key}`);
  }

  if (key[0] !== '/') {
    key = '/' + key;
  }

  template = templates[key];

  if (typeof template !== 'undefined') {
    return template;
  }

  throw new Error(`Appsync mapping template not found: ${key}`);
};

getDataSource = function (item) {
  if (item.Lambda) {
    return {
      type: 'lambda',
      key: (0, _checksum2.default)(JSON.stringify({
        lambda: item.Lambda
      })),
      value: item.Lambda
    };
  }

  return {
    type: 'none',
    key: 'none'
  };
};

;