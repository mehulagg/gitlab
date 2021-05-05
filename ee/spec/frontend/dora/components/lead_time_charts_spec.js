import { GlSprintf } from '@gitlab/ui';
import { mount, shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { useFixturesFakeDate } from 'helpers/fake_date';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';
import CiCdAnalyticsCharts from '~/vue_shared/components/ci_cd_analytics/ci_cd_analytics_charts.vue';

jest.mock('~/flash');

const lastWeekData = getJSONFixture(
  'api/dora/metrics/daily_lead_time_for_changes_for_last_week.json',
);
const lastMonthData = getJSONFixture(
  'api/dora/metrics/daily_lead_time_for_changes_for_last_month.json',
);
const last90DaysData = getJSONFixture(
  'api/dora/metrics/daily_lead_time_for_changes_for_last_90_days.json',
);

describe('lead_time_charts.vue', () => {
  useFixturesFakeDate();

  let LeadTimeCharts;
  let DoraChartHeader;

  // Import these components _after_ the date has been set using `useFakeDate`, so
  // that any calls to `new Date()` during module initialization use the fake date
  beforeAll(async () => {
    LeadTimeCharts = (await import('ee_component/dora/components/lead_time_charts.vue')).default;
    DoraChartHeader = (await import('ee/dora/components/dora_chart_header.vue')).default;
  });

  let wrapper;
  let mock;

  const createComponent = (mountFn = shallowMount) => {
    wrapper = mountFn(LeadTimeCharts, {
      provide: {
        projectPath: 'test/project',
      },
      stubs: { GlSprintf },
    });
  };

  // Initializes the mock endpoint to return a specific set of lead time data for a given "from" date.
  const setUpMockLeadTime = ({ start_date, data }) => {
    mock
      .onGet(/projects\/test%2Fproject\/dora\/metrics/, {
        params: {
          metric: 'lead_time_for_changes',
          interval: 'daily',
          per_page: 100,
          end_date: '2015-07-04T00:00:00+0000',
          start_date,
        },
      })
      .replyOnce(httpStatus.OK, data);
  };

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  const getTooltipValue = () => wrapper.find('[data-testid="tooltip-value"]').text();
  const findCiCdAnalyticsCharts = () => wrapper.findComponent(CiCdAnalyticsCharts);

  describe('when there are no network errors', () => {
    beforeEach(async () => {
      mock = new MockAdapter(axios);

      setUpMockLeadTime({
        start_date: '2015-06-27T00:00:00+0000',
        data: lastWeekData,
      });
      setUpMockLeadTime({
        start_date: '2015-06-04T00:00:00+0000',
        data: lastMonthData,
      });
      setUpMockLeadTime({
        start_date: '2015-04-05T00:00:00+0000',
        data: last90DaysData,
      });

      createComponent();

      await axios.waitForAll();
    });

    it('makes 3 GET requests - one for each chart', () => {
      expect(mock.history.get).toHaveLength(3);
    });

    it('does not show a flash message', () => {
      expect(createFlash).not.toHaveBeenCalled();
    });

    it('renders a header', () => {
      expect(wrapper.findComponent(DoraChartHeader).exists()).toBe(true);
    });

    describe('methods', () => {
      describe('formatTooltipText', () => {
        it('displays a humanized version of the time interval in the tooltip', async () => {
          createComponent(mount);

          await axios.waitForAll();

          const params = { seriesData: [{}, { data: ['Apr 7', 5328] }] };

          // Simulate the child CiCdAnalyticsCharts component calling the
          // function bound to the `format-tooltip-text`.
          const formatTooltipText = findCiCdAnalyticsCharts().vm.$attrs['format-tooltip-text'];
          formatTooltipText(params);

          await wrapper.vm.$nextTick();

          expect(getTooltipValue()).toBe('1.5 hours');
        });
      });
    });
  });

  describe('when there are network errors', () => {
    beforeEach(async () => {
      mock = new MockAdapter(axios);

      createComponent();

      await axios.waitForAll();
    });

    it('shows a flash message', () => {
      expect(createFlash).toHaveBeenCalledTimes(1);
      expect(createFlash.mock.calls[0]).toEqual([
        {
          message: 'Something went wrong while getting lead time data.',
          captureError: true,
          error: expect.any(Error),
        },
      ]);
    });
  });
});
