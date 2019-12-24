import { shallowMount } from '@vue/test-utils';

import { GlButton } from '@gitlab/ui';
import DropdownHeader from 'ee/vue_shared/components/sidebar/epics_select/dropdown_header.vue';
import Icon from '~/vue_shared/components/icon.vue';

describe('EpicsSelect', () => {
  describe('DropdownHeader', () => {
    let wrapper;

    beforeEach(() => {
      wrapper = shallowMount(DropdownHeader, {
        sync: false,
      });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    describe('template', () => {
      it('should render container element', () => {
        expect(wrapper.classes()).toContain('dropdown-title');
      });

      it('should render title', () => {
        expect(wrapper.find('span').text()).toBe('Assign epic');
      });

      it('should render close button', () => {
        const buttonEl = wrapper.find(GlButton);

        expect(buttonEl.exists()).toBe(true);
        expect(buttonEl.attributes('aria-label')).toBe('Close');
        expect(buttonEl.classes()).toEqual(
          expect.arrayContaining(['dropdown-title-button', 'dropdown-menu-close']),
        );
      });

      it('should render close button icon', () => {
        const iconEl = wrapper.find(GlButton).find(Icon);

        expect(iconEl.exists()).toBe(true);
        expect(iconEl.attributes('name')).toBe('close');
      });
    });
  });
});
