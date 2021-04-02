import $ from 'jquery';
import initBroadcastMessagesForm from './broadcast_message';

document.addEventListener('DOMContentLoaded', () => {
  initBroadcastMessagesForm();

  $('.js-remove-tr').on('ajax:before', function removeTRAjaxBeforeCallback() {
    $(this).parent().find('.btn').addClass('disabled');
  });

  $('.js-remove-tr').on('ajax:success', function removeTRAjaxSuccessCallback() {
    $(this).closest('tr').addClass('gl-display-none!');
  });
});
