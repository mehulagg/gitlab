import $ from 'jquery';
import { __ } from '~/locale';
import initDeprecatedJQueryDropdown from '~/deprecated_jquery_dropdown';

export default class CiTemplate {
  constructor() {
    this.$input = $('#required_instance_ci_template_name');
    this.$dropdown = $('.js-ci-template-dropdown');
    this.$dropdownToggle = this.$dropdown.find('.dropdown-toggle-text');
    this.initDropdown();
  }

  initDropdown() {
    initDeprecatedJQueryDropdown(this.$dropdown, {
      data: this.formatDropdownList(),
      selectable: true,
      filterable: true,
      allowClear: true,
      toggleLabel: (item) => item.name,
      search: {
        fields: ['name'],
      },
      clicked: (clickEvent) => this.updateInputValue(clickEvent),
      text: (item) => item.name,
    });

    this.setDropdownToggle();
  }

  formatDropdownList() {
    return {
      Reset: [
        {
          name: __('No required pipeline'),
          id: null,
        },
        {
          type: 'divider',
        },
      ],
      ...this.$dropdown.data('data'),
    };
  }

  setDropdownToggle() {
    const initialValue = this.$input.val();

    if (initialValue) {
      this.$dropdownToggle.text(initialValue);
    }
  }

  updateInputValue({ selectedObj, e }) {
    e.preventDefault();

    this.$input.val(selectedObj.id);
  }
}
