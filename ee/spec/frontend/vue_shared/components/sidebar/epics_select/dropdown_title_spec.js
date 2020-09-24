import { shallowMount } from '@vue/test-utils';

import { GlLoadingIcon, GlLink } from '@gitlab/ui';

import DropdownTitle from 'ee/vue_shared/components/sidebar/epics_select/dropdown_title.vue';

describe('EpicsSelect', () => {
  describe('DropdownTitle', () => {
    let wrapper;

    beforeEach(() => {
      wrapper = shallowMount(DropdownTitle, {
        propsData: {
          canEdit: false,
          blockTitle: 'Epic',
        },
      });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    describe('template', () => {
      it('should render component container', () => {
        expect(wrapper.classes()).toEqual(expect.arrayContaining(['title', 'hide-collapsed']));
      });

      it('should render title element', () => {
        wrapper.setProps({
          isLoading: true,
        });

        return wrapper.vm.$nextTick().then(() => {
          const titleEl = wrapper.find('.flex-grow-1');

          expect(titleEl.exists()).toBe(true);
          expect(titleEl.find('span').classes()).toContain('align-text-top');
          expect(titleEl.find('span').text()).toBe('Epic');
        });
      });

      it('should render loading icon when `isLoading` prop is true', () => {
        wrapper.setProps({
          isLoading: true,
        });

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
        });
      });

      it('should render edit link when `canEdit` prop is true', () => {
        wrapper.setProps({
          canEdit: true,
        });

        return wrapper.vm.$nextTick().then(() => {
          const editEl = wrapper.find(GlLink);

          expect(editEl.exists()).toBe(true);
          expect(editEl.classes()).toContain('sidebar-dropdown-toggle');
          expect(editEl.text()).toBe('Edit');
        });
      });
    });
  });
});
