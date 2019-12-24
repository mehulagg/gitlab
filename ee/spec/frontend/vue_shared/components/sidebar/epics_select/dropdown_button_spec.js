import { shallowMount } from '@vue/test-utils';

import DropdownButton from 'ee/vue_shared/components/sidebar/epics_select/dropdown_button.vue';
import Icon from '~/vue_shared/components/icon.vue';

describe('EpicsSelect', () => {
  describe('DropdownButton', () => {
    let wrapper;

    beforeEach(() => {
      wrapper = shallowMount(DropdownButton, {
        sync: false,
      });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    describe('template', () => {
      it('should render button element', () => {
        expect(wrapper.is('button')).toBe(true);
        expect(wrapper.classes()).toEqual(
          expect.arrayContaining(['dropdown-menu-toggle', 'js-epic-select', 'js-extra-options']),
        );
        expect(wrapper.attributes('data-display')).toBe('static');
        expect(wrapper.attributes('data-toggle')).toBe('dropdown');
      });

      it('should render button title', () => {
        const titleEl = wrapper.find('.dropdown-toggle-text');

        expect(titleEl.exists()).toBe(true);
        expect(titleEl.text()).toBe('Epic');
      });

      it('should render Icon component', () => {
        const iconEl = wrapper.find(Icon);

        expect(iconEl.exists()).toBe(true);
        expect(iconEl.attributes('name')).toBe('chevron-down');
      });
    });
  });
});
