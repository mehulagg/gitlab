import $ from 'jquery';
import UsersSelect from '~/users_select';
import AbuseReports from './abuse_reports';

new AbuseReports(); /* eslint-disable-line no-new */
new UsersSelect(); /* eslint-disable-line no-new */

document.addEventListener('DOMContentLoaded', () => {
  $('.js-remove-tr').on('ajax:before', function removeTRAjaxBeforeCallback() {
    $(this).parent().find('.btn').addClass('disabled');
  });

  $('.js-remove-tr').on('ajax:success', function removeTRAjaxSuccessCallback() {
    $(this).closest('tr').addClass('gl-display-none!');
  });
});
