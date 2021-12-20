"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (context) {
  var bucket, defaultRegion, description, entry, j, len, outputs, profile, ref, regions, resources, stack, stacks;
  stack = context.string('@Config.Stack', 'stack');
  defaultRegion = context.string('@Config.Region', 'us-east-1');
  profile = context.string('@Config.Profile', 'default');
  bucket = context.string('@Config.DeploymentBucket', '');
  description = context.string('@Config.Description', '');
  outputs = context.getOutputs();
  resources = context.getResources();
  regions = [...find(outputs), ...find(resources)].filter(function (i) {
    return i;
  });
  regions = [...new Set([...regions, defaultRegion])]; // console.log regions

  stacks = regions.map(function (region) {
    return {
      name: stack,
      stack,
      bucket,
      region,
      profile,
      templateBody: {
        AWSTemplateFormatVersion: '2010-09-09',
        Description: description,
        Resources: filter(resources, defaultRegion, region),
        Outputs: filter(outputs, defaultRegion, region)
      }
    };
  });
  ref = context.getDefinedStacks();

  for (j = 0, len = ref.length; j < len; j++) {
    entry = ref[j];
    stacks.push({
      name: entry.name || stack,
      stack: entry.name || stack,
      bucket,
      region: entry.region || defaultRegion,
      profile: entry.profile || profile,
      templateBody: {
        AWSTemplateFormatVersion: '2010-09-09',
        Description: entry.description || '',
        Resources: entry.resources,
        Outputs: entry.outputs || []
      }
    });
  }

  return stacks;
};

var filter, find;

find = function (list) {
  var item, name, regions;
  regions = [];

  for (name in list) {
    item = list[name];
    regions.push(item.Region);
  }

  return regions;
};

filter = function (list, defaultRegion, filterRegion) {
  var filtered, item, name, region;
  filtered = {};

  for (name in list) {
    item = list[name];
    region = item.Region || item.Properties && item.Properties.Region || defaultRegion; // console.log name, region

    if (region === filterRegion) {
      filtered[name] = item;
    }
  }

  return filtered;
};

;