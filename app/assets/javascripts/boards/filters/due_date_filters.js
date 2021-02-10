import dateFormat from 'dateformat';
import Vue from '~/lib/vue_with_runtime_compiler';

Vue.filter('due-date', (value) => {
  const date = new Date(value);
  return dateFormat(date, 'mmm d, yyyy', true);
});
