import { GlTabs, GlTab } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CiCdAnalyticsApp from 'ee/analytics/group_ci_cd_analytics/components/app.vue';
import ReleaseStatsCard from 'ee/analytics/group_ci_cd_analytics/components/release_stats_card.vue';
import setWindowLocation from 'helpers/set_window_location_helper';
import { TEST_HOST } from 'helpers/test_constants';
import { getParameterValues } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility');

describe('ee/analytics/group_ci_cd_analytics/components/app.vue', () => {
  let wrapper;

  beforeEach(() => {
    getParameterValues.mockReturnValue([]);
  });

  const createComponent = () => {
    wrapper = shallowMount(CiCdAnalyticsApp);
  };

  const findGlTabs = () => wrapper.findComponent(GlTabs);
  const findAllGlTabs = () => wrapper.findAllComponents(GlTab);
  const findGlTabAtIndex = (index) => findAllGlTabs().at(index);

  describe('tabs', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders tabs in the correct order', () => {
      expect(findGlTabs().exists()).toBe(true);

      expect(findGlTabAtIndex(0).attributes('title')).toBe('Release statistics');
    });
  });

  describe('release statistics', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the release statistics component inside the first tab', () => {
      expect(findGlTabAtIndex(0).find(ReleaseStatsCard).exists()).toBe(true);
    });
  });

  describe('when provided with a query param', () => {
    it.each`
      tab                     | index
      ${'release-statistics'} | ${'0'}
      ${'fake'}               | ${'0'}
      ${''}                   | ${'0'}
    `('shows the correct tab for URL parameter "$tab"', ({ tab, index }) => {
      setWindowLocation(`${TEST_HOST}/groups/gitlab-org/gitlab/-/analytics/ci_cd?tab=${tab}`);
      getParameterValues.mockImplementation((name) => {
        expect(name).toBe('tab');
        return tab ? [tab] : [];
      });
      createComponent();
      expect(findGlTabs().attributes('value')).toBe(index);
    });
  });
});
