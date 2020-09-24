import { shallowMount } from '@vue/test-utils';

import { GlLink, GlDeprecatedBadge as GlBadge, GlButton } from '@gitlab/ui';

import RequirementsTabs from 'ee/requirements/components/requirements_tabs.vue';
import { FilterState } from 'ee/requirements/constants';

import { mockRequirementsCount } from '../mock_data';

const createComponent = ({
  filterBy = FilterState.opened,
  requirementsCount = mockRequirementsCount,
  showCreateForm = false,
  canCreateRequirement = true,
} = {}) =>
  shallowMount(RequirementsTabs, {
    propsData: {
      filterBy,
      requirementsCount,
      showCreateForm,
      canCreateRequirement,
    },
  });

describe('RequirementsTabs', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('template', () => {
    it('renders "Open" tab', () => {
      const tabEl = wrapper.findAll(GlLink).at(0);

      expect(tabEl.attributes('id')).toBe('state-opened');
      expect(tabEl.attributes('data-state')).toBe('opened');
      expect(tabEl.attributes('title')).toBe('Filter by requirements that are currently opened.');
      expect(tabEl.text()).toContain('Open');
      expect(tabEl.find(GlBadge).text()).toBe(`${mockRequirementsCount.OPENED}`);
    });

    it('renders "Archived" tab', () => {
      const tabEl = wrapper.findAll(GlLink).at(1);

      expect(tabEl.attributes('id')).toBe('state-archived');
      expect(tabEl.attributes('data-state')).toBe('archived');
      expect(tabEl.attributes('title')).toBe('Filter by requirements that are currently archived.');
      expect(tabEl.text()).toContain('Archived');
      expect(tabEl.find(GlBadge).text()).toBe(`${mockRequirementsCount.ARCHIVED}`);
    });

    it('renders "All" tab', () => {
      const tabEl = wrapper.findAll(GlLink).at(2);

      expect(tabEl.attributes('id')).toBe('state-all');
      expect(tabEl.attributes('data-state')).toBe('all');
      expect(tabEl.attributes('title')).toBe('Show all requirements.');
      expect(tabEl.text()).toContain('All');
      expect(tabEl.find(GlBadge).text()).toBe(`${mockRequirementsCount.ALL}`);
    });

    it('renders class `active` on currently selected tab', () => {
      const tabEl = wrapper.findAll('li').at(0);

      expect(tabEl.classes()).toContain('active');
    });

    it('renders "New requirement" button when current tab is "Open" tab', () => {
      wrapper.setProps({
        filterBy: FilterState.opened,
      });

      return wrapper.vm.$nextTick(() => {
        const buttonEl = wrapper.find(GlButton);

        expect(buttonEl.exists()).toBe(true);
        expect(buttonEl.text()).toBe('New requirement');
      });
    });

    it('does not render "New requirement" button when current tab is not "Open" tab', () => {
      wrapper.setProps({
        filterBy: FilterState.closed,
      });

      return wrapper.vm.$nextTick(() => {
        const buttonEl = wrapper.find(GlButton);

        expect(buttonEl.exists()).toBe(false);
      });
    });

    it('does not render "New requirement" button when `canCreateRequirement` prop is false', () => {
      wrapper.setProps({
        filterBy: FilterState.opened,
        canCreateRequirement: false,
      });

      return wrapper.vm.$nextTick(() => {
        const buttonEl = wrapper.find(GlButton);

        expect(buttonEl.exists()).toBe(false);
      });
    });

    it('disables "New requirement" button when `showCreateForm` is true', () => {
      wrapper.setProps({
        showCreateForm: true,
      });

      return wrapper.vm.$nextTick(() => {
        const buttonEl = wrapper.find(GlButton);

        expect(buttonEl.props('disabled')).toBe(true);
      });
    });
  });
});
