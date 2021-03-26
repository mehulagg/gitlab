import { GlTab, GlBadge } from '@gitlab/ui';
import { mount } from '@vue/test-utils';

import IssuableTabs from '~/issuable_list/components/issuable_tabs.vue';

import { mockIssuableListProps } from '../mock_data';

const createComponent = ({
  tabs = mockIssuableListProps.tabs,
  tabCounts = mockIssuableListProps.tabCounts,
  currentTab = mockIssuableListProps.currentTab,
} = {}) =>
  mount(IssuableTabs, {
    propsData: {
      tabs,
      tabCounts,
      currentTab,
    },
    slots: {
      'nav-actions': `
      <button class="js-new-issuable">New issuable</button>
    `,
    },
  });

describe('IssuableTabs', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('methods', () => {
    describe('isTabActive', () => {
      it.each`
        tabName     | currentTab  | returnValue
        ${'opened'} | ${'opened'} | ${true}
        ${'opened'} | ${'closed'} | ${false}
      `(
        'returns $returnValue when tab name is "$tabName" is current tab is "$currentTab"',
        async ({ tabName, currentTab, returnValue }) => {
          wrapper.setProps({
            currentTab,
          });

          await wrapper.vm.$nextTick();

          expect(wrapper.vm.isTabActive(tabName)).toBe(returnValue);
        },
      );
    });
  });

  describe('template', () => {
    it('renders gl-tab for each tab within `tabs` array', () => {
      const tabsEl = wrapper.findAll(GlTab);

      expect(tabsEl.exists()).toBe(true);
      expect(tabsEl).toHaveLength(mockIssuableListProps.tabs.length);
    });

    it('renders gl-badge component within a tab', () => {
      const badgeEl = wrapper.findAll(GlBadge);

      // Does not render `All` tab since it has an undefined count
      expect(badgeEl).toHaveLength(2);
      expect(badgeEl.at(0).text()).toBe(`${mockIssuableListProps.tabCounts.opened}`);
      expect(badgeEl.at(1).text()).toBe(`${mockIssuableListProps.tabCounts.closed}`);
    });

    it('renders contents for slot "nav-actions"', () => {
      const buttonEl = wrapper.find('button.js-new-issuable');

      expect(buttonEl.exists()).toBe(true);
      expect(buttonEl.text()).toBe('New issuable');
    });
  });

  describe('events', () => {
    it('gl-tab component emits `click` event on `click` event', () => {
      const tabEl = wrapper.findAll(GlTab).at(0);

      tabEl.vm.$emit('click', 'opened');

      expect(wrapper.emitted('click')).toBeTruthy();
      expect(wrapper.emitted('click')[0]).toEqual(['opened']);
    });
  });
});
