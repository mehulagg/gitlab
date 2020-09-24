import { shallowMount } from '@vue/test-utils';

import LicenseManagementRow from 'ee/vue_shared/license_compliance/components/license_management_row.vue';
import {
  approvedLicense,
  blacklistedLicense,
} from 'ee_jest/vue_shared/license_compliance/mock_data';

let wrapper;

describe('LicenseManagementRow', () => {
  afterEach(() => {
    wrapper.destroy();
  });

  describe('allowed license', () => {
    beforeEach(() => {
      const props = { license: approvedLicense };

      wrapper = shallowMount(LicenseManagementRow, {
        propsData: {
          ...props,
        },
      });
    });

    it('renders the license name', () => {
      expect(wrapper.find('.name').element).toMatchSnapshot();
    });

    it('renders the allowed status text with the status icon', () => {
      expect(wrapper.find('.status').element).toMatchSnapshot();
    });
  });

  describe('denied license', () => {
    beforeEach(() => {
      const props = { license: blacklistedLicense };

      wrapper = shallowMount(LicenseManagementRow, {
        propsData: {
          ...props,
        },
      });
    });

    it('renders the license name', () => {
      expect(wrapper.find('.name').element).toMatchSnapshot();
    });

    it('renders the denied status text with the status icon', () => {
      expect(wrapper.find('.status').element).toMatchSnapshot();
    });
  });
});
