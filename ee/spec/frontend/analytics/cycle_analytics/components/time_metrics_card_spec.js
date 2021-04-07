import { shallowMount } from '@vue/test-utils';
import TimeMetricsCard from 'ee/analytics/cycle_analytics/components/time_metrics_card.vue';
import { OVERVIEW_METRICS } from 'ee/analytics/cycle_analytics/constants';
import Api from 'ee/api';
import createFlash from '~/flash';
import { group, timeMetricsData, recentActivityData } from '../mock_data';

jest.mock('~/flash');

describe('TimeMetricsCard', () => {
  const { full_path: groupPath } = group;
  let wrapper;

  const template = `
    <div slot-scope="{ metrics }">
      <span v-for="metric in metrics">{{metric.value}} {{metric.unit}}</span>
    </div>`;

  const createComponent = ({ additionalParams = {}, requestType } = {}) => {
    return shallowMount(TimeMetricsCard, {
      propsData: {
        groupPath,
        additionalParams,
        requestType,
      },
      scopedSlots: {
        default: template,
      },
    });
  };

  describe.each`
    metric               | requestType                         | request                            | data
    ${'Recent activity'} | ${OVERVIEW_METRICS.RECENT_ACTIVITY} | ${'cycleAnalyticsSummaryData'}     | ${recentActivityData}
    ${'Time summary'}    | ${OVERVIEW_METRICS.TIME_SUMMARY}    | ${'cycleAnalyticsTimeSummaryData'} | ${timeMetricsData}
  `('$metric', ({ requestType, request, data, metric }) => {
    beforeEach(() => {
      jest.spyOn(Api, request).mockResolvedValue({ data });
      wrapper = createComponent({ requestType });
    });

    afterEach(() => {
      wrapper.destroy();
      wrapper = null;
    });

    it(`renders the ${metric} metric`, () => {
      expect(wrapper.html()).toMatchSnapshot();
    });

    it('fetches the metric data', () => {
      expect(Api[request]).toHaveBeenCalledWith(groupPath, {});
    });

    describe('with a failing request', () => {
      beforeEach(() => {
        jest.spyOn(Api, request).mockRejectedValue();
        wrapper = createComponent({ requestType });
      });

      it('should render an error message', () => {
        expect(createFlash).toHaveBeenCalledWith({
          message: `There was an error while fetching value stream analytics ${metric.toLowerCase()} data.`,
        });
      });
    });

    describe('with additional params', () => {
      beforeEach(() => {
        wrapper = createComponent({
          requestType,
          additionalParams: {
            'project_ids[]': [1],
            created_after: '2020-01-01',
            created_before: '2020-02-01',
          },
        });
      });

      it('sends additional parameters as query paremeters', () => {
        expect(Api[request]).toHaveBeenCalledWith(groupPath, {
          'project_ids[]': [1],
          created_after: '2020-01-01',
          created_before: '2020-02-01',
        });
      });
    });
  });
});
