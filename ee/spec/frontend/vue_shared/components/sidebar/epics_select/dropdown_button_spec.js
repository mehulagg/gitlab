import { GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import DropdownButton from 'ee/vue_shared/components/sidebar/epics_select/dropdown_button.vue';

import { mockEpic1 } from '../mock_data';

describe('EpicsSelect', () => {
  describe('DropdownButton', () => {
    let wrapper;
    let wrapperWithEpic;

    beforeEach(() => {
      wrapper = shallowMount(DropdownButton);
      wrapperWithEpic = shallowMount(DropdownButton, {
        propsData: {
          selectedEpicTitle: mockEpic1.title,
        },
      });
    });

    afterEach(() => {
      wrapper.destroy();
      wrapperWithEpic.destroy();
    });

    describe('computed', () => {
      describe('buttonText', () => {
        it('returns string "Epic" when `selectedEpicTitle` prop is empty', () => {
          expect(wrapper.vm.buttonText).toBe('Epic');
        });

        it('returns string containing `selectedEpicTitle`', () => {
          expect(wrapperWithEpic.vm.buttonText).toBe(mockEpic1.title);
        });
      });
    });

    describe('template', () => {
      it('should render button element', () => {
        expect(wrapper.element.tagName).toBe('BUTTON');
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

        const titleWithEpicEl = wrapperWithEpic.find('.dropdown-toggle-text');

        expect(titleWithEpicEl.exists()).toBe(true);
        expect(titleWithEpicEl.text()).toBe(mockEpic1.title);
      });

      it('should render button title with toggleTextClass prop value', () => {
        wrapper.setProps({
          toggleTextClass: { 'is-default': true },
        });

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.find('.dropdown-toggle-text').classes()).toContain('is-default');
        });
      });

      it('should render Icon component', () => {
        const iconEl = wrapper.find(GlIcon);

        expect(iconEl.exists()).toBe(true);
        expect(iconEl.attributes('name')).toBe('chevron-down');
      });
    });
  });
});
