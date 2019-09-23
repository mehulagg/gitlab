import _ from 'lodash-es';
import './polyfills';
import './jquery';
import './bootstrap';
import './vue';
import '../lib/utils/axios_utils';
import { openUserCountsBroadcast } from './nav/user_merge_requests';

openUserCountsBroadcast();

// underscore compatibility
_.mapObject = _.mapValues;

// The following can be refactored because underscore has aliases.
_.any = _.some;
_.contains = _.includes;
_.pluck = _.map;
