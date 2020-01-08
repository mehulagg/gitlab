import { shallowMount } from '@vue/test-utils';
import { GlAlert, GlEmptyState } from '@gitlab/ui';
import { TEST_HOST } from 'helpers/test_constants';
import createStore from 'ee/threat_monitoring/store';
import ThreatMonitoringApp from 'ee/threat_monitoring/components/app.vue';
import ThreatMonitoringFilters from 'ee/threat_monitoring/components/threat_monitoring_filters.vue';
import WafLoadingSkeleton from 'ee/threat_monitoring/components/waf_loading_skeleton.vue';
import WafStatisticsHistory from 'ee/threat_monitoring/components/waf_statistics_history.vue';
import WafStatisticsSummary from 'ee/threat_monitoring/components/waf_statistics_summary.vue';

const defaultEnvironmentId = 3;
const documentationPath = '/docs';
const emptyStateSvgPath = '/svgs';
const environmentsEndpoint = `${TEST_HOST}/environments`;
const wafStatisticsEndpoint = `${TEST_HOST}/waf`;

describe('ThreatMonitoringApp component', () => {
  let store;
  let wrapper;

  const factory = propsData => {
    store = createStore();
    Object.assign(store.state.threatMonitoring, {
      environmentsEndpoint,
      wafStatisticsEndpoint,
    });

    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(ThreatMonitoringApp, {
      propsData,
      store,
      sync: false,
    });
  };

  const findAlert = () => wrapper.find(GlAlert);
  const findWafLoadingSkeleton = () => wrapper.find(WafLoadingSkeleton);
  const findWafStatisticsHistory = () => wrapper.find(WafStatisticsHistory);
  const findWafStatisticsSummary = () => wrapper.find(WafStatisticsSummary);

  afterEach(() => {
    wrapper.destroy();
  });

  describe.each([-1, NaN, Math.PI])(
    'given an invalid default environment id of %p',
    invalidEnvironmentId => {
      beforeEach(() => {
        factory({
          defaultEnvironmentId: invalidEnvironmentId,
          emptyStateSvgPath,
          documentationPath,
        });
      });

      it('dispatches no actions', () => {
        expect(store.dispatch).not.toHaveBeenCalled();
      });

      it('shows only the empty state', () => {
        const emptyState = wrapper.find(GlEmptyState);
        expect(wrapper.element).toBe(emptyState.element);
        expect(emptyState.props()).toMatchObject({
          svgPath: emptyStateSvgPath,
          primaryButtonLink: documentationPath,
        });
      });
    },
  );

  describe('given there is a default environment', () => {
    beforeEach(() => {
      factory({
        defaultEnvironmentId,
        emptyStateSvgPath,
        documentationPath,
      });
    });

    it('dispatches the setCurrentEnvironmentId and fetchEnvironments actions', () => {
      expect(store.dispatch.mock.calls).toEqual([
        ['threatMonitoring/setCurrentEnvironmentId', defaultEnvironmentId],
        ['threatMonitoring/fetchEnvironments', undefined],
      ]);
    });

    it('shows the alert', () => {
      expect(findAlert().element).toMatchSnapshot();
    });

    it('shows the filter bar', () => {
      expect(wrapper.find(ThreatMonitoringFilters).exists()).toBe(true);
    });

    it('shows the summary and history statistics', () => {
      expect(findWafStatisticsSummary().exists()).toBe(true);
      expect(findWafStatisticsHistory().exists()).toBe(true);
    });

    it('does not show the loading skeleton', () => {
      expect(findWafLoadingSkeleton().exists()).toBe(false);
    });

    describe('dismissing the alert', () => {
      beforeEach(() => {
        findAlert().vm.$emit('dismiss');
        return wrapper.vm.$nextTick();
      });

      it('hides the alert', () => {
        expect(findAlert().exists()).toBe(false);
      });
    });

    describe('given the statistics are loading', () => {
      beforeEach(() => {
        store.state.threatMonitoring.isLoadingWafStatistics = true;
      });

      it('does not show the summary or history statistics', () => {
        expect(findWafStatisticsSummary().exists()).toBe(false);
        expect(findWafStatisticsHistory().exists()).toBe(false);
      });

      it('displays the loading skeleton', () => {
        expect(findWafLoadingSkeleton().exists()).toBe(true);
      });
    });
  });
});
