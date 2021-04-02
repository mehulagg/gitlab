import $ from 'jquery';

document.addEventListener('DOMContentLoaded', () => {
  $('.js-remove-tr').on('ajax:before', function removeTRAjaxBeforeCallback() {
    $(this).addClass('disabled');
  });

  $('.js-remove-tr').on('ajax:success', function removeTRAjaxSuccessCallback() {
    $(this).closest('tr').addClass('gl-display-none!');
  });
});
