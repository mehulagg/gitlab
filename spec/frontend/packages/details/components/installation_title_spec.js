import { shallowMount } from '@vue/test-utils';

import InstallationTitle from '~/packages/details/components/installation_title.vue';
import PersistedDropdownSelection from '~/vue_shared/components/registry/persisted_dropdown_selection.vue';

describe('InstallationTitle', () => {
  let wrapper;

  const defaultProps = { storageKey: 'foo', options: [{ value: 'foo', label: 'bar' }] };

  const findPersistedDropdownSelection = () => wrapper.findComponent(PersistedDropdownSelection);
  const findTitle = () => wrapper.find('h3');

  function createComponent({ props = {} } = {}) {
    wrapper = shallowMount(InstallationTitle, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  it('has a title', () => {
    createComponent();

    expect(findTitle().exists()).toBe(true);
    expect(findTitle().text()).toBe('Installation');
  });

  describe('persisted dropdown selection', () => {
    it('exists', () => {
      createComponent();

      expect(findPersistedDropdownSelection().exists()).toBe(true);
    });

    it('has the correct props', () => {
      createComponent();

      expect(findPersistedDropdownSelection().props()).toMatchObject(defaultProps);
    });

    it('on change event emits a change event', () => {
      createComponent();

      findPersistedDropdownSelection().vm.$emit('change', 'baz');

      expect(wrapper.emitted('change')).toEqual([['baz']]);
    });
  });
});
