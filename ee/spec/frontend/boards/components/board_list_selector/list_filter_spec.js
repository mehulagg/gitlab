import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import ListFilter from 'ee/boards/components/boards_list_selector/list_filter.vue';

describe('ListFilter', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(ListFilter);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('input field', () => {
    it('emits `onSearchInput` event on keyup and sends input text as event param', () => {
      const input = wrapper.find('input');
      input.setValue('foobar');
      input.trigger('keyup');

      expect(wrapper.emitted().onSearchInput[0]).toEqual(['foobar']);
    });
  });

  describe('clear button', () => {
    let input;

    beforeEach(() => {
      // Pre-populate input field with text
      input = wrapper.find('input');
      input.setValue('foobar');
      input.trigger('keyup');
    });

    it('clears input field and emits `onSearchInput` event with empty value', () => {
      expect(input.element.value).toBe('foobar');

      wrapper.find('.dropdown-input-clear').vm.$emit('click');

      return Vue.nextTick().then(() => {
        expect(input.element.value).toBe('');
        expect(wrapper.emitted().onSearchInput[1]).toEqual(['']);
      });
    });
  });

  describe('template', () => {
    it('renders component container element with class `dropdown-input`', () => {
      expect(wrapper.classes('dropdown-input')).toBe(true);
    });

    it('renders class `has-value` on container element when prop `query` is not empty', () => {
      wrapper.setData({ query: 'foobar' });

      return Vue.nextTick().then(() => {
        expect(wrapper.classes('has-value')).toBe(true);
      });
    });

    it('removes class `has-value` from container element when prop `query` is empty', () => {
      wrapper.setData({ query: '' });

      return Vue.nextTick().then(() => {
        expect(wrapper.classes('has-value')).toBe(false);
      });
    });

    it('renders search input element', () => {
      const inputEl = wrapper.find('input.dropdown-input-field');

      expect(inputEl.exists()).toBe(true);
      expect(inputEl.attributes('placeholder')).toBe('Search');
    });

    it('renders search input icons', () => {
      expect(wrapper.find('.dropdown-input-search').exists()).toBe(true);
      expect(wrapper.find('.dropdown-input-clear').exists()).toBe(true);
    });
  });
});
