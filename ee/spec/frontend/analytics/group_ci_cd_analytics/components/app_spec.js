import { shallowMount } from '@vue/test-utils';
import CiCdAnalyticsApp from 'ee/analytics/group_ci_cd_analytics/components/app.vue';
import ReleaseStatsCard from 'ee/analytics/group_ci_cd_analytics/components/release_stats_card.vue';

describe('ee/analytics/group_ci_cd_analytics/components/app.vue', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(CiCdAnalyticsApp);
  };

  it('renders the release stats card', () => {
    createComponent();
    expect(wrapper.find(ReleaseStatsCard).exists()).toBe(true);
  });
});
