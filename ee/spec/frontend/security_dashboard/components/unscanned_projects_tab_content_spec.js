import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';

import UnscannedProjectsTabContent from 'ee/security_dashboard/components/unscanned_projects_tab_content.vue';

const localVue = createLocalVue();

describe('UnscannedProjectTabContent Component', () => {
  let wrapper;

  const factory = (propsData = {}) => {
    wrapper = shallowMount(UnscannedProjectsTabContent, {
      propsData,
      slots: { default: '<span class="default-slot"></span>' },
      localVue,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const defaultSlot = () => wrapper.find('.default-slot');

  describe('default state', () => {
    beforeEach(factory);

    it('does not contain a loading icon', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    });

    it('renders the default slot', () => {
      expect(defaultSlot().exists()).toBe(true);
    });
  });

  describe('loading state', () => {
    beforeEach(() => {
      factory({ isLoading: true });
    });

    it('contains a loading icon', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe('empty state', () => {
    beforeEach(() => {
      factory({ isEmpty: true });
    });

    it('does not render the default slot', () => {
      expect(defaultSlot().exists()).toBe(false);
    });

    it('contains a message to indicate that all projects are up to date', () => {
      expect(wrapper.text()).toContain('Your projects are up do date');
    });
  });
});
