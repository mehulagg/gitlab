import $ from 'jquery';
import initDeprecatedJQueryDropdown from '~/deprecated_jquery_dropdown';

export default () => {
  initDeprecatedJQueryDropdown($('.js-diff-stats-dropdown'), {
    filterable: true,
    remoteFilter: false,
  });
};
