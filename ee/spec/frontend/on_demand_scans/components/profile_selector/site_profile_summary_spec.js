import { shallowMount } from '@vue/test-utils';
import App from 'ee/on_demand_scans/components/profile_selector/site_profile_summary';
import { siteProfiles } from 'ee_jest/on_demand_scans/mocks/mock_data';

const [profile] = siteProfiles;

describe('DastSiteProfileSummary', () => {
  let wrapper;

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(App, {
      propsData: {
        profile,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders properly', () => {
    createWrapper();

    expect(wrapper.element).toMatchSnapshot();
  });
});
