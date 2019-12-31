import { createLocalVue, shallowMount } from '@vue/test-utils';

import { GlButton } from '@gitlab/ui';
import DropdownSearchInput from 'ee/vue_shared/components/sidebar/epics_select/dropdown_search_input.vue';
import Icon from '~/vue_shared/components/icon.vue';

const createComponent = () => {
  const localVue = createLocalVue();

  return shallowMount(DropdownSearchInput, {
    localVue,
    directives: {
      /**
       * We don't want any observers
       * initialized during tests that this
       * directive does.
       */
      autofocusonshow: {},
    },
  });
};

describe('EpicsSelect', () => {
  describe('DropdownSearchInput', () => {
    let wrapper;

    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    describe('methods', () => {
      describe('handleKeyUp', () => {
        it('should emit `onSearchInput` on component with `query` param', () => {
          jest.spyOn(wrapper.vm, '$emit');
          wrapper.setData({
            query: 'foo',
          });

          wrapper.vm.handleKeyUp();

          expect(wrapper.vm.$emit).toHaveBeenCalledWith('onSearchInput', 'foo');
        });
      });

      describe('handleInputClear', () => {
        it('should set `query` prop to empty string and calls `handleKeyUp`', () => {
          jest.spyOn(wrapper.vm, 'handleKeyUp');
          wrapper.setData({
            query: 'foo',
          });

          wrapper.vm.handleInputClear();

          expect(wrapper.vm.query).toBe('');
          expect(wrapper.vm.handleKeyUp).toHaveBeenCalled();
        });
      });
    });

    describe('template', () => {
      it('should render component container', () => {
        expect(wrapper.classes()).toContain('dropdown-input');
        expect(wrapper.classes()).not.toContain('has-value');
      });

      it('should add `has-value` class to container when `query` prop is not empty', () => {
        wrapper.setData({
          query: 'foo',
        });

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.classes()).toContain('has-value');
        });
      });

      it('should render input element', () => {
        const inputEl = wrapper.find('input');

        expect(inputEl.exists()).toBe(true);
        expect(inputEl.classes()).toContain('dropdown-input-field');
        expect(inputEl.attributes('placeholder')).toBe('Search');
        expect(inputEl.attributes('type')).toBe('search');
        expect(inputEl.attributes('autocomplete')).toBe('off');
      });

      it('should render Icon component', () => {
        wrapper.setData({
          query: 'foo',
        });

        return wrapper.vm.$nextTick().then(() => {
          const iconEl = wrapper.find(Icon);

          expect(iconEl.exists()).toBe(true);
          expect(iconEl.attributes('name')).toBe('search');
        });
      });

      it('should render input clear button', () => {
        const clearButtonEl = wrapper.find(GlButton);

        expect(clearButtonEl.exists()).toBe(true);
        expect(clearButtonEl.classes()).toEqual(
          expect.arrayContaining([
            'fa',
            'fa-times',
            'dropdown-input-clear',
            'js-dropdown-input-clear',
          ]),
        );
      });
    });
  });
});
