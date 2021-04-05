import $ from 'jquery';
import * as tooltips from '~/tooltips';

document.addEventListener('DOMContentLoaded', () => {
  $('.remove-row').on('ajax:success', function removeRowAjaxSuccessCallback() {
    tooltips.dispose(this);

    $(this).closest('li').addClass('gl-display-none!');
  });
});
