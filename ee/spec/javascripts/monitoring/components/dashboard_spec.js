import { shallowMount, createLocalVue } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { GlModal, GlButton } from '@gitlab/ui';
import Dashboard from 'ee/monitoring/components/dashboard.vue';
import {
  metricsGroupsAPIResponse,
  mockApiEndpoint,
  mockedQueryResultPayload,
  environmentData,
} from 'spec/monitoring/mock_data';
import propsData from 'spec/monitoring/components/dashboard_spec';
import CustomMetricsFormFields from 'ee/custom_metrics/components/custom_metrics_form_fields.vue';
import Tracking from '~/tracking';
import { createStore } from '~/monitoring/stores';
import axios from '~/lib/utils/axios_utils';
import * as types from '~/monitoring/stores/mutation_types';

const localVue = createLocalVue();

describe('Dashboard', () => {
  let Component;
  let mock;
  let store;
  let wrapper;

  const findAddMetricButton = () => wrapper.vm.$refs.addMetricBtn;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(localVue.extend(Component), {
      propsData: {
        ...propsData,
        ...props,
      },
      stubs: {
        GlButton,
      },
      store,
      sync: false,
      localVue,
    });
  };

  beforeEach(() => {
    setFixtures(`
      <div class="prometheus-graphs"></div>
      <div class="layout-page"></div>
    `);

    window.gon = {
      ...window.gon,
      ee: true,
    };

    store = createStore();
    mock = new MockAdapter(axios);
    mock.onGet(mockApiEndpoint).reply(200, metricsGroupsAPIResponse);
    Component = localVue.extend(Dashboard);
  });

  afterEach(() => {
    mock.restore();
  });

  function setupComponentStore(component) {
    component.vm.$store.commit(
      `monitoringDashboard/${types.RECEIVE_METRICS_DATA_SUCCESS}`,
      metricsGroupsAPIResponse,
    );
    component.vm.$store.commit(
      `monitoringDashboard/${types.RECEIVE_METRIC_RESULT_SUCCESS}`,
      mockedQueryResultPayload,
    );
    component.vm.$store.commit(
      `monitoringDashboard/${types.RECEIVE_ENVIRONMENTS_DATA_SUCCESS}`,
      environmentData,
    );
  }

  describe('add custom metrics', () => {
    const defaultProps = {
      customMetricsPath: '/endpoint',
      hasMetrics: true,
      documentationPath: '/path/to/docs',
      settingsPath: '/path/to/settings',
      clustersPath: '/path/to/clusters',
      projectPath: '/path/to/project',
      metricsEndpoint: mockApiEndpoint,
      tagsPath: '/path/to/tags',
      emptyGettingStartedSvgPath: '/path/to/getting-started.svg',
      emptyLoadingSvgPath: '/path/to/loading.svg',
      emptyNoDataSvgPath: '/path/to/no-data.svg',
      emptyNoDataSmallSvgPath: '/path/to/no-data-small.svg',
      emptyUnableToConnectSvgPath: '/path/to/unable-to-connect.svg',
      environmentsEndpoint: '/root/hello-prometheus/environments/35',
      currentEnvironmentName: 'production',
      prometheusAlertsAvailable: true,
      alertsEndpoint: '/endpoint',
    };

    describe('when not available', () => {
      beforeEach(() => {
        createComponent({
          customMetricsAvailable: false,
          ...defaultProps,
        });
      });

      it('does not render add button on the dashboard', () => {
        expect(findAddMetricButton()).toBeUndefined();
      });
    });

    describe('when available', () => {
      let origPage;

      beforeEach(done => {
        spyOn(Tracking, 'event');

        createComponent({
          customMetricsAvailable: true,
          ...defaultProps,
        });

        setupComponentStore(wrapper);

        origPage = document.body.dataset.page;
        document.body.dataset.page = 'projects:environments:metrics';

        wrapper.vm.$nextTick(done);
      });

      afterEach(() => {
        document.body.dataset.page = origPage;
      });

      it('renders add button on the dashboard', () => {
        expect(findAddMetricButton()).toBeDefined();
      });

      it('uses modal for custom metrics form', () => {
        expect(wrapper.find(GlModal).exists()).toBe(true);
        expect(wrapper.find(GlModal).attributes().modalid).toBe('add-metric');
      });

      it('adding new metric is tracked', done => {
        const submitButton = wrapper.vm.$refs.submitCustomMetricsFormBtn;
        wrapper.setData({ formIsValid: true });
        wrapper.vm.$nextTick(() => {
          // eslint-disable-next-line no-jquery/no-event-shorthand
          submitButton.$el.click();
          wrapper.vm.$nextTick(() => {
            expect(Tracking.event).toHaveBeenCalledWith(
              document.body.dataset.page,
              'click_button',
              {
                label: 'add_new_metric',
                property: 'modal',
                value: undefined,
              },
            );
            done();
          });
        });
      });

      it('renders custom metrics form fields', () => {
        expect(wrapper.find(CustomMetricsFormFields).exists()).toBe(true);
      });
    });
  });
});
