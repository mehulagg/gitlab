import { GlAlert } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import ThreatMonitoringAlerts from 'ee/threat_monitoring/components/alerts/alerts.vue';
import ThreatMonitoringApp from 'ee/threat_monitoring/components/app.vue';
import ThreatMonitoringFilters from 'ee/threat_monitoring/components/threat_monitoring_filters.vue';
import NetworkPolicyList from 'ee/threat_monitoring/components/network_policy_list.vue';
import NoEnvironmentEmptyState from 'ee/threat_monitoring/components/no_environment_empty_state.vue';
import createStore from 'ee/threat_monitoring/store';
import { TEST_HOST } from 'helpers/test_constants';
import axios from '~/lib/utils/axios_utils';

const defaultEnvironmentId = 3;
const documentationPath = '/docs';
const newPolicyPath = '/policy/new';
const chartEmptyStateSvgPath = '/chart-svgs';
const emptyStateSvgPath = '/svgs';
const wafNoDataSvgPath = '/waf-no-data-svg';
const networkPolicyNoDataSvgPath = '/network-policy-no-data-svg';
const environmentsEndpoint = `${TEST_HOST}/environments`;
const wafStatisticsEndpoint = `${TEST_HOST}/waf`;
const networkPolicyStatisticsEndpoint = `${TEST_HOST}/network_policy`;
const userCalloutId = 'threat_monitoring_info';
const userCalloutsPath = `${TEST_HOST}/user_callouts`;

describe('ThreatMonitoringApp component', () => {
  let store;
  let wrapper;

  const factory = ({ propsData, provide = {}, state, stubs = {} } = {}) => {
    store = createStore();
    Object.assign(store.state.threatMonitoring, {
      environmentsEndpoint,
      wafStatisticsEndpoint,
      networkPolicyStatisticsEndpoint,
      ...state,
    });

    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = extendedWrapper(
      shallowMount(ThreatMonitoringApp, {
        propsData: {
          defaultEnvironmentId,
          chartEmptyStateSvgPath,
          emptyStateSvgPath,
          wafNoDataSvgPath,
          networkPolicyNoDataSvgPath,
          newPolicyPath,
          showUserCallout: true,
          userCalloutId,
          userCalloutsPath,
          ...propsData,
        },
        provide: {
          documentationPath,
          glFeatures: { threatMonitoringAlerts: false },
          ...provide,
        },
        store,
        stubs,
      }),
    );
  };

  const findAlert = () => wrapper.find(GlAlert);
  const findAlertsView = () => wrapper.find(ThreatMonitoringAlerts);
  const findNetworkPolicyList = () => wrapper.find(NetworkPolicyList);
  const findFilters = () => wrapper.find(ThreatMonitoringFilters);
  const findWafSection = () => wrapper.find({ ref: 'wafSection' });
  const findNetworkPolicySection = () => wrapper.find({ ref: 'networkPolicySection' });
  const findNoEnvironmentEmptyStates = () => wrapper.findAll(NoEnvironmentEmptyState);
  const findNetworkPolicyTab = () => wrapper.find({ ref: 'networkPolicyTab' });
  const findAlertTab = () => wrapper.findByTestId('threat-monitoring-alerts-tab');
  const findStatisticsTab = () => wrapper.findByTestId('threat-monitoring-statistics-tab');

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe.each([-1, NaN, Math.PI])(
    'given an invalid default environment id of %p',
    (invalidEnvironmentId) => {
      beforeEach(() => {
        factory({
          propsData: {
            defaultEnvironmentId: invalidEnvironmentId,
          },
          stubs: { GlTabs: false },
        });
      });

      it('dispatches no actions', () => {
        expect(store.dispatch).not.toHaveBeenCalled();
      });

      it('shows the "no environment" empty state', () => {
        expect(findNoEnvironmentEmptyStates().length).toBe(2);
      });

      it('shows the tabs', () => {
        expect(findNetworkPolicyTab().exists()).toBe(true);
        expect(findStatisticsTab().exists()).toBe(true);
      });

      it('does not show the network policy list', () => {
        expect(findNetworkPolicyList().exists()).toBe(false);
      });

      it('does not show the threat monitoring section', () => {
        expect(findNetworkPolicySection().exists()).toBe(false);
      });
    },
  );

  describe('given there is a default environment with data', () => {
    beforeEach(() => {
      factory();
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
      expect(findFilters().exists()).toBe(true);
    });

    it('renders the waf section', () => {
      expect(findWafSection().element).toMatchSnapshot();
    });

    it('renders the network policy section', () => {
      expect(findNetworkPolicySection().element).toMatchSnapshot();
    });

    it('renders the network policy tab', () => {
      expect(findNetworkPolicyTab().element).toMatchSnapshot();
    });

    it('does not show the alert tab', () => {
      expect(findAlertTab().exists()).toBe(false);
    });

    describe('dismissing the alert', () => {
      let mockAxios;

      beforeEach(() => {
        mockAxios = new MockAdapter(axios);
        mockAxios.onPost(userCalloutsPath, { feature_name: userCalloutId }).reply(200);

        findAlert().vm.$emit('dismiss');
        return wrapper.vm.$nextTick();
      });

      afterEach(() => {
        mockAxios.restore();
      });

      it('hides the alert', () => {
        expect(findAlert().exists()).toBe(false);
      });

      it('posts the dismissal to the user callouts endpoint', () => {
        expect(mockAxios.history.post).toHaveLength(1);
      });
    });
  });

  describe('given showUserCallout is false', () => {
    beforeEach(() => {
      factory({
        propsData: {
          showUserCallout: false,
        },
      });
    });

    it('does not render the alert', () => {
      expect(findAlert().exists()).toBe(false);
    });
  });

  describe('alerts tab', () => {
    beforeEach(() => {
      factory({ provide: { glFeatures: { threatMonitoringAlerts: true } } });
    });
    it('shows the alerts tab', () => {
      expect(findAlertTab().exists()).toBe(true);
    });
    it('shows the default alerts component', () => {
      expect(findAlertsView().exists()).toBe(true);
    });
  });
});
