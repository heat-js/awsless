"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (events) {
  var currentEvents, event, i, j, k, len, len1, len2;
  currentEvents = [];

  for (i = 0, len = events.length; i < len; i++) {
    event = events[i];
    currentEvents.unshift(event);

    if (event.ResourceStatusReason === 'User Initiated') {
      break;
    }
  } // switch event.ResourceStatus
  // 	when 'UPDATE_IN_PROGRESS', 'CREATE_IN_PROGRESS'
  // 		break


  for (j = 0, len1 = currentEvents.length; j < len1; j++) {
    event = currentEvents[j];

    if (event.ResourceStatus.includes('FAILED')) {
      return `[${event.LogicalResourceId}] ${event.ResourceStatusReason}`;
    }
  }

  for (k = 0, len2 = events.length; k < len2; k++) {
    event = events[k];

    if (event.ResourceStatus.includes('FAILED')) {
      return `[${event.LogicalResourceId}] ${event.ResourceStatusReason}`;
    }
  }

  return 'Unknown error';
};

;