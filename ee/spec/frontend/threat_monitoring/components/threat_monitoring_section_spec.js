import { shallowMount } from '@vue/test-utils';
import LoadingSkeleton from 'ee/threat_monitoring/components/loading_skeleton.vue';
import StatisticsHistory from 'ee/threat_monitoring/components/statistics_history.vue';
import StatisticsSummary from 'ee/threat_monitoring/components/statistics_summary.vue';
import ThreatMonitoringSection from 'ee/threat_monitoring/components/threat_monitoring_section.vue';
import createStore from 'ee/threat_monitoring/store';

import { mockNominalHistory, mockAnomalousHistory } from '../mocks/mock_data';

describe('ThreatMonitoringSection component', () => {
  let store;
  let wrapper;

  const timeRange = {
    from: new Date(Date.UTC(2020, 2, 6)).toISOString(),
    to: new Date(Date.UTC(2020, 2, 13)).toISOString(),
  };

  const factory = ({ propsData, state } = {}) => {
    store = createStore();
    Object.assign(store.state.threatMonitoringNetworkPolicy, {
      isLoadingStatistics: false,
      statistics: {
        total: 100,
        anomalous: 0.2,
        history: {
          nominal: mockNominalHistory,
          anomalous: mockAnomalousHistory,
        },
      },
      timeRange,
      ...state,
    });

    jest.spyOn(store, 'dispatch').mockImplementation(() => Promise.resolve());

    wrapper = shallowMount(ThreatMonitoringSection, {
      propsData: {
        storeNamespace: 'threatMonitoringNetworkPolicy',
        title: 'Container Network Policy',
        subtitle: 'Requests',
        nominalTitle: 'Total Requests',
        anomalousTitle: 'Anomalous Requests',
        yLegend: 'Requests',
        chartEmptyStateTitle: 'Empty Title',
        chartEmptyStateText: 'Empty Text',
        chartEmptyStateSvgPath: 'svg_path',
        documentationPath: 'documentation_path',
        documentationAnchor: 'anchor',
        ...propsData,
      },
      store,
    });
  };

  const findLoadingSkeleton = () => wrapper.find(LoadingSkeleton);
  const findStatisticsHistory = () => wrapper.find(StatisticsHistory);
  const findStatisticsSummary = () => wrapper.find(StatisticsSummary);
  const findChartEmptyState = () => wrapper.find({ ref: 'chartEmptyState' });
  const findChartTitle = () => wrapper.find({ ref: 'chartTitle' });
  const findChartSubtitle = () => wrapper.find({ ref: 'chartSubtitle' });

  beforeEach(() => {
    factory({});
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('does not show the loading skeleton', () => {
    expect(findLoadingSkeleton().exists()).toBe(false);
  });

  it('sets data to the summary', () => {
    const summary = findStatisticsSummary();
    expect(summary.exists()).toBe(true);

    expect(summary.props('data')).toStrictEqual({
      anomalous: {
        title: 'Anomalous Requests',
        value: 0.2,
      },
      nominal: {
        title: 'Total Requests',
        value: 100,
      },
    });
  });

  it('sets data to the chart', () => {
    const chart = findStatisticsHistory();
    expect(chart.exists()).toBe(true);

    expect(chart.props('data')).toStrictEqual({
      anomalous: { title: 'Anomalous Requests', values: mockAnomalousHistory },
      nominal: { title: 'Total Requests', values: mockNominalHistory },
      ...timeRange,
    });
    expect(chart.props('yLegend')).toEqual('Requests');
  });

  it('shows the chart title', () => {
    expect(findChartTitle().exists()).toBe(true);
  });

  it('shows the chart subtitle', () => {
    expect(findChartSubtitle().exists()).toBe(true);
  });

  it('does not show the chart empty state', () => {
    expect(findChartEmptyState().exists()).toBe(false);
  });

  it('fetches statistics', () => {
    expect(store.dispatch).toHaveBeenCalledWith('threatMonitoringNetworkPolicy/fetchStatistics');
  });

  it('fetches statistics on environment change', async () => {
    store.dispatch.mockReset();
    await store.commit('threatMonitoring/SET_CURRENT_ENVIRONMENT_ID', 2);

    expect(store.dispatch).toHaveBeenCalledWith('threatMonitoringNetworkPolicy/fetchStatistics');
  });

  it('fetches statistics on time window change', async () => {
    store.dispatch.mockReset();
    await store.commit('threatMonitoring/SET_CURRENT_TIME_WINDOW', 'hour');

    expect(store.dispatch).toHaveBeenCalledWith('threatMonitoringNetworkPolicy/fetchStatistics');
  });

  describe('given the statistics are loading', () => {
    beforeEach(() => {
      factory({
        state: { isLoadingStatistics: true },
      });
    });

    it('shows the loading skeleton', () => {
      expect(findLoadingSkeleton().element).toMatchSnapshot();
    });

    it('does not show the summary or history statistics', () => {
      expect(findStatisticsSummary().exists()).toBe(false);
      expect(findStatisticsHistory().exists()).toBe(false);
    });

    it('shows the chart title', () => {
      expect(findChartTitle().exists()).toBe(true);
    });

    it('does not show the chart subtitle', () => {
      expect(findChartSubtitle().exists()).toBe(false);
    });

    it('does not show the chart empty state', () => {
      expect(findChartEmptyState().exists()).toBe(false);
    });
  });

  describe('given there is a default environment with no data to display', () => {
    beforeEach(() => {
      factory({
        state: {
          statistics: {
            total: 100,
            anoumalous: 0.2,
            history: { nominal: [], anomalous: [] },
          },
        },
      });
    });

    it('does not show the loading skeleton', () => {
      expect(findLoadingSkeleton().exists()).toBe(false);
    });

    it('does not show the summary or history statistics', () => {
      expect(findStatisticsSummary().exists()).toBe(false);
      expect(findStatisticsHistory().exists()).toBe(false);
    });

    it('shows the chart title', () => {
      expect(findChartTitle().exists()).toBe(true);
    });

    it('does not show the chart subtitle', () => {
      expect(findChartSubtitle().exists()).toBe(false);
    });

    it('shows the chart empty state', () => {
      expect(findChartEmptyState().element).toMatchSnapshot();
    });
  });
});
