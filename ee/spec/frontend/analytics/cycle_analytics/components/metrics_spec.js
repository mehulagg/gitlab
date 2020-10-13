import { shallowMount } from '@vue/test-utils';
import Metrics from 'ee/analytics/cycle_analytics/components/metrics.vue';
import TimeMetricsCard from 'ee/analytics/cycle_analytics/components/time_metrics_card.vue';
import { OVERVIEW_METRICS } from 'ee/analytics/cycle_analytics/constants';
import { group } from '../mock_data';

describe('Metrics', () => {
  const { full_path: groupPath } = group;
  let wrapper;

  const createComponent = ({ requestParams = {} } = {}) => {
    return shallowMount(Metrics, {
      propsData: {
        groupPath,
        requestParams,
      },
    });
  };

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findTimeMetricsAtIndex = index => wrapper.findAll(TimeMetricsCard).at(index);

  it.each`
    metric               | index | requestType
    ${'time summary'}    | ${0}  | ${OVERVIEW_METRICS.TIME_SUMMARY}
    ${'recent activity'} | ${1}  | ${OVERVIEW_METRICS.RECENT_ACTIVITY}
  `('renders the $metric', ({ index, requestType }) => {
    const card = findTimeMetricsAtIndex(index);
    expect(card.props('requestType')).toBe(requestType);
    expect(card.html()).toMatchSnapshot();
  });
});
