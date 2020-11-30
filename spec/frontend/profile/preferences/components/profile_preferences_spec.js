import { shallowMount } from '@vue/test-utils';

import ProfilePreferences from '~/profile/preferences/components/profile_preferences.vue';
import IntegrationView from '~/profile/preferences/components/integration_view.vue';
import GroupOverviewSelector from '~/profile/preferences/components/group_overview_selector.vue';
import {
  firstDayOfWeekChoicesWithDefault,
  dashboardChoices,
  layoutChoices,
  languageChoices,
  projectViewChoices,
  integrationViews,
  userFields,
  featureFlags,
} from '../mock_data';

describe('ProfilePreferences component', () => {
  let wrapper;
  const defaultProvide = {
    firstDayOfWeekChoicesWithDefault,
    dashboardChoices,
    layoutChoices,
    languageChoices,
    projectViewChoices,
    integrationViews: [],
    userFields,
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
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('Group view section', () => {
    it('should render the empty component', () => {
      wrapper = createComponent();
      const groupOverviewSelector = wrapper.find(GroupOverviewSelector);
      // exists() returns false on an empty wrapper: https://vue-test-utils.vuejs.org/api/wrapper/#exists
      expect(groupOverviewSelector.exists()).toBe(false);
    });
  });

  describe('Integrations section', () => {
    it('should not render', () => {
      wrapper = createComponent();
      const views = wrapper.findAll(IntegrationView);
      const divider = wrapper.find('[data-testid="profile-preferences-integrations-rule"]');
      const heading = wrapper.find('[data-testid="profile-preferences-integrations-heading"]');

      expect(divider.exists()).toBe(false);
      expect(heading.exists()).toBe(false);
      expect(views).toHaveLength(0);
    });

    it('should render', () => {
      wrapper = createComponent({ provide: { integrationViews } });
      const divider = wrapper.find('[data-testid="profile-preferences-integrations-rule"]');
      const heading = wrapper.find('[data-testid="profile-preferences-integrations-heading"]');
      const views = wrapper.findAll(IntegrationView);

      expect(divider.exists()).toBe(true);
      expect(heading.exists()).toBe(true);
      expect(views).toHaveLength(integrationViews.length);
    });
  });

  describe('with `viewDiffsFileByFile` feature flag enabled', () => {
    it('should render diffs by file settings', () => {
      wrapper = createComponent({ provide: { featureFlags } });
      const diffsByFile = wrapper.find('[data-testid="view-diffs-file-by-file"]');
      expect(diffsByFile.exists()).toBe(true);
    });
  });

  describe('with `viewDiffsFileByFile` feature flag disabled', () => {
    it('should not render diffs by file settings', () => {
      wrapper = createComponent();
      const diffsByFile = wrapper.find('[data-testid="view-diffs-file-by-file"]');
      expect(diffsByFile.exists()).toBe(false);
    });
  });

  describe('with `userTimeSettings` feature flag enabled', () => {
    it('should render user time settings', () => {
      wrapper = createComponent({ provide: { featureFlags } });
      const userTimeSettingsRule = wrapper.find('[data-testid="user-time-settings-rule"]');
      const userTimeSettingsHeading = wrapper.find('[data-testid="user-time-settings-heading"]');
      const userTimeSettingsOption = wrapper.find('[data-testid="user-time-settings-option"]');
      expect(userTimeSettingsRule.exists()).toBe(true);
      expect(userTimeSettingsHeading.exists()).toBe(true);
      expect(userTimeSettingsOption.exists()).toBe(true);
    });
  });

  describe('with `userTimeSettings` feature flag disabled', () => {
    it('should not render user time settings', () => {
      wrapper = createComponent();
      const userTimeSettingsRule = wrapper.find('[data-testid="user-time-settings-rule"]');
      const userTimeSettingsHeading = wrapper.find('[data-testid="user-time-settings-heading"]');
      const userTimeSettingsOption = wrapper.find('[data-testid="user-time-settings-option"]');
      expect(userTimeSettingsRule.exists()).toBe(false);
      expect(userTimeSettingsHeading.exists()).toBe(false);
      expect(userTimeSettingsOption.exists()).toBe(false);
    });
  });

  it('should render ProfilePreferences properly', () => {
    wrapper = createComponent({
      provide: {
        integrationViews,
        featureFlags,
      },
    });

    expect(wrapper.element).toMatchSnapshot();
  });
});
