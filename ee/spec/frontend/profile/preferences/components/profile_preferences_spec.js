import { shallowMount } from '@vue/test-utils';

import GroupOverviewSelector from 'ee/profile/preferences/components/group_overview_selector.vue';
import ProfilePreferences from '~/profile/preferences/components/profile_preferences.vue';
import { groupViewChoices } from '../mock_data';

describe('ProfilePreferences component', () => {
  let wrapper;
  const defaultProvide = {
    firstDayOfWeekChoicesWithDefault: [],
    dashboardChoices: [],
    layoutChoices: [],
    languageChoices: [],
    projectViewChoices: [],
    groupViewChoices: [],
    integrationViews: [],
    userFields: {},
    featureFlags: {},
  };

  function createComponent(options = {}) {
    const { props = {}, provide = {} } = options;
    return shallowMount(ProfilePreferences, {
      provide: {
        ...defaultProvide,
        ...provide,
      },
      propsData: props,
      stubs: {
        GroupOverviewSelector,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('Group view section', () => {
    it('should render the component', () => {
      wrapper = createComponent();
      const groupOverviewSelector = wrapper.find(GroupOverviewSelector);
      expect(groupOverviewSelector.exists()).toBe(true);
    });

    it('should not render the heading', () => {
      wrapper = createComponent();
      const groupOverviewHeading = wrapper.find(
        '[data-testid="profile-preferences-group-overview-heading"]',
      );
      expect(groupOverviewHeading.exists()).toBe(false);
    });

    it('should render the heading', () => {
      wrapper = createComponent({ provide: { groupViewChoices } });
      const groupOverviewHeading = wrapper.find(
        '[data-testid="profile-preferences-group-overview-heading"]',
      );
      expect(groupOverviewHeading.exists()).toBe(true);
    });

    it('should not render the options', () => {
      wrapper = createComponent();
      const groupOverviewOptions = wrapper.findAll(
        '[data-testid="profile-preferences-group-overview-option"]',
      );
      expect(groupOverviewOptions).toHaveLength(0);
    });

    it('should render the options', () => {
      wrapper = createComponent({ provide: { groupViewChoices } });
      const groupOverviewOptions = wrapper.findAll(
        '[data-testid="profile-preferences-group-overview-option"]',
      );
      expect(groupOverviewOptions).toHaveLength(groupViewChoices.length);
    });
  });

  it('should render ProfilePreferences properly', () => {
    wrapper = createComponent({
      provide: { groupViewChoices },
    });

    expect(wrapper.element).toMatchSnapshot();
  });
});
