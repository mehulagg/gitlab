import { shallowMount } from '@vue/test-utils';
import $ from 'jquery';
import Dropdown from 'ee/vue_shared/license_compliance/components/add_license_form_dropdown.vue';

let vm;
let wrapper;

const KNOWN_LICENSES = ['AGPL-1.0', 'AGPL-3.0', 'Apache 2.0', 'BSD'];

const createComponent = (props = {}) => {
  wrapper = shallowMount(Dropdown, { propsData: { knownLicenses: KNOWN_LICENSES, ...props } });
  vm = wrapper.vm;
};

describe('AddLicenseFormDropdown', () => {
  afterEach(() => {
    vm = undefined;
    wrapper.destroy();
  });

  it('emits `input` invent on change', () => {
    createComponent();

    jest.spyOn(vm, '$emit').mockImplementation(() => {});

    $(vm.$el)
      .val('LGPL')
      .trigger('change');

    expect(vm.$emit).toHaveBeenCalledWith('input', 'LGPL');
  });

  it('sets the placeholder appropriately', () => {
    const placeholder = 'Select a license';
    createComponent({ placeholder });

    const dropdownContainer = $(vm.$el).select2('container')[0];

    expect(dropdownContainer.textContent).toContain(placeholder);
  });

  it('sets the initial value correctly', () => {
    const value = 'AWESOME_LICENSE';
    createComponent({ value });

    expect(vm.$el.value).toContain(value);
  });

  it('shows all defined licenses', done => {
    createComponent();

    const element = $(vm.$el);

    element.on('select2-open', () => {
      const options = $('.select2-drop .select2-result');

      expect(KNOWN_LICENSES).toHaveLength(options.length);
      options.each((index, optionEl) => {
        expect(KNOWN_LICENSES).toContain($(optionEl).text());
      });
      done();
    });

    element.select2('open');
  });
});
