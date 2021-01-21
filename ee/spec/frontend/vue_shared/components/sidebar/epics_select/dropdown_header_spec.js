import { GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import DropdownHeader from 'ee/vue_shared/components/sidebar/epics_select/dropdown_header.vue';

describe('EpicsSelect', () => {
  describe('DropdownHeader', () => {
    let wrapper;

    beforeEach(() => {
      wrapper = shallowMount(DropdownHeader);
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
        expect(buttonEl.props('icon')).toBe('close');
      });
    });
  });
});
