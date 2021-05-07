import * as Sentry from '@sentry/browser';
import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { useFixturesFakeDate } from 'helpers/fake_date';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';
import CiCdAnalyticsCharts from '~/vue_shared/components/ci_cd_analytics/ci_cd_analytics_charts.vue';

jest.mock('~/flash');

const lastWeekData = getJSONFixture(
  'api/dora/metrics/daily_deployment_frequency_for_last_week.json',
);
const lastMonthData = getJSONFixture(
  'api/dora/metrics/daily_deployment_frequency_for_last_month.json',
);
const last90DaysData = getJSONFixture(
  'api/dora/metrics/daily_deployment_frequency_for_last_90_days.json',
);

describe('deployment_frequency_charts.vue', () => {
  useFixturesFakeDate();

  let DeploymentFrequencyCharts;
  let DoraChartHeader;

  // Import these components _after_ the date has been set using `useFakeDate`, so
  // that any calls to `new Date()` during module initialization use the fake date
  beforeAll(async () => {
    DeploymentFrequencyCharts = (
      await import('ee_component/dora/components/deployment_frequency_charts.vue')
    ).default;
    DoraChartHeader = (await import('ee/dora/components/dora_chart_header.vue')).default;
  });

  let wrapper;
  let mock;

  const createComponent = () => {
    wrapper = shallowMount(DeploymentFrequencyCharts, {
      provide: {
        projectPath: 'test/project',
      },
    });
  };

  // Initializes the mock endpoint to return a specific set of deployment
  // frequency data for a given "from" date.
  const setUpMockDeploymentFrequencies = ({ start_date, data }) => {
    mock
      .onGet(/projects\/test%2Fproject\/dora\/metrics/, {
        params: {
          metric: 'deployment_frequency',
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
    wrapper = null;
    mock.restore();
  });

  describe('when there are no network errors', () => {
    beforeEach(async () => {
      mock = new MockAdapter(axios);

      setUpMockDeploymentFrequencies({
        start_date: '2015-06-27T00:00:00+0000',
        data: lastWeekData,
      });
      setUpMockDeploymentFrequencies({
        start_date: '2015-06-04T00:00:00+0000',
        data: lastMonthData,
      });
      setUpMockDeploymentFrequencies({
        start_date: '2015-04-05T00:00:00+0000',
        data: last90DaysData,
      });

      createComponent();

      await axios.waitForAll();
    });

    it('makes 3 GET requests - one for each chart', () => {
      expect(mock.history.get).toHaveLength(3);
    });

    it('converts the data from the API into data usable by the chart component', () => {
      const chartWrapper = wrapper.findComponent(CiCdAnalyticsCharts);
      expect(chartWrapper.props().charts).toMatchSnapshot();
    });

    it('does not show a flash message', () => {
      expect(createFlash).not.toHaveBeenCalled();
    });

    it('renders a header', () => {
      expect(wrapper.findComponent(DoraChartHeader).exists()).toBe(true);
    });
  });

  describe('when there are network errors', () => {
    let captureExceptionSpy;
    beforeEach(async () => {
      mock = new MockAdapter(axios);

      createComponent();

      captureExceptionSpy = jest.spyOn(Sentry, 'captureException');

      await axios.waitForAll();
    });

    afterEach(() => {
      captureExceptionSpy.mockRestore();
    });

    it('shows a flash message', () => {
      expect(createFlash).toHaveBeenCalledTimes(1);
      expect(createFlash).toHaveBeenCalledWith({
        message: 'Something went wrong while getting deployment frequency data.',
      });
    });

    it('reports an error to Sentry', () => {
      expect(captureExceptionSpy).toHaveBeenCalledTimes(1);

      const expectedErrorMessage = [
        'Something went wrong while getting deployment frequency data:',
        'Error: Request failed with status code 404',
        'Error: Request failed with status code 404',
        'Error: Request failed with status code 404',
      ].join('\n');

      expect(captureExceptionSpy).toHaveBeenCalledWith(new Error(expectedErrorMessage));
    });
  });
});
