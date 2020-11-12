/* eslint-disable no-shadow */

import $ from 'jquery';
import initDeprecatedJQueryDropdown from '~/deprecated_jquery_dropdown';

function WeightSelect(els, options = {}) {
  const $els = $(els || '.js-weight-select');

  $els.each((i, dropdown) => {
    const $dropdown = $(dropdown);
    const $selectbox = $dropdown.closest('.selectbox');
    const $block = $selectbox.closest('.block');
    const $value = $block.find('.value');
    // eslint-disable-next-line no-jquery/no-fade
    $block.find('.block-loading').fadeOut();
    const fieldName = options.fieldName || $dropdown.data('fieldName');
    const inputField = $dropdown.closest('.selectbox').find(`input[name='${fieldName}']`);

    if (Object.keys(options).includes('selected')) {
      inputField.val(options.selected);
    }

    return initDeprecatedJQueryDropdown($dropdown, {
      selectable: true,
      fieldName,
      toggleLabel(selected, el) {
        return $(el).data('id');
      },
      hidden() {
        $selectbox.hide();
        return $value.css('display', '');
      },
      id(obj, el) {
        if ($(el).data('none') == null) {
          return $(el).data('id');
        }
        return '';
      },
      clicked(deprecatedJQueryDropdownEvt) {
        const { e } = deprecatedJQueryDropdownEvt;
        let selected = deprecatedJQueryDropdownEvt.selectedObj;
        const inputField = $dropdown.closest('.selectbox').find(`input[name='${fieldName}']`);

        if (options.handleClick) {
          e.preventDefault();
          selected = inputField.val();
          options.handleClick(selected);
        } else if ($dropdown.is('.js-issuable-form-weight')) {
          e.preventDefault();
        }
      },
    });
  });
}

export default WeightSelect;
