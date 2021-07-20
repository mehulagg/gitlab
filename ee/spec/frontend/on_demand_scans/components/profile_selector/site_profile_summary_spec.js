import { shallowMount } from '@vue/test-utils';
import App from 'ee/on_demand_scans/components/profile_selector/site_profile_summary.vue';
import { siteProfiles } from 'ee_jest/on_demand_scans/mocks/mock_data';

describe('DastSiteProfileSummary', () => {
  let wrapper;

  const createWrapper = (profile = {}) => {
    wrapper = shallowMount(App, {
      propsData: {
        profile,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('renders properly', () => {
    it.each(siteProfiles)('profile %#', (profile) => {
      createWrapper(profile);

      expect(wrapper.element).toMatchSnapshot();
    });
  });
});
