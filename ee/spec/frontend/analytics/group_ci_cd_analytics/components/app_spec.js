import { shallowMount } from '@vue/test-utils';
import CiCdAnalyticsApp from 'ee/analytics/group_ci_cd_analytics/components/app.vue';

describe('ee/analytics/group_ci_cd_analytics/components/app.vue', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(CiCdAnalyticsApp);
  };

  it('renders without errors', () => {
    createComponent();

    expect(wrapper).toBeTruthy();
  });
});
