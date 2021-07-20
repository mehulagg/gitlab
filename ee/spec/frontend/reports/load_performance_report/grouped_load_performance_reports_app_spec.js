import { mount, createLocalVue } from '@vue/test-utils';
import GroupedLoadPerformanceReportsApp from 'ee/reports/load_performance_report/grouped_load_performance_reports_app.vue';
import Api from '~/api';

jest.mock('~/api.js');

const localVue = createLocalVue();

describe('Grouped load performance reports app', () => {
  let wrapper;

  const mountComponent = ({ usageDataITestingLoadPerformanceWidgetTotal = false } = {}) => {
    wrapper = mount(GroupedLoadPerformanceReportsApp, {
      localVue,
      propsData: {
        status: '',
        loadingText: '',
        errorText: '',
        successText: '',
        unresolvedIssues: [{}, {}],
        resolvedIssues: [],
        neutralIssues: [],
        hasIssues: true,
      },
      provide: {
        glFeatures: {
          usageDataITestingLoadPerformanceWidgetTotal,
        },
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('service ping events', () => {
    describe('when feature flag is enabled', () => {
      beforeEach(() => {
        mountComponent({ usageDataITestingLoadPerformanceWidgetTotal: true });
      });

      it('tracks an event when the widget is expanded', () => {
        wrapper.find('[data-testid="report-section-expand-button"]').trigger('click');

        expect(Api.trackRedisHllUserEvent).toHaveBeenCalledWith(wrapper.vm.$options.expandEvent);
      });
    });

    describe('when feature flag is disabled', () => {
      beforeEach(() => {
        mountComponent({ usageDataITestingLoadPerformanceWidgetTotal: false });
      });

      it('tracks an event when the widget is expanded', () => {
        wrapper.find('[data-testid="report-section-expand-button"]').trigger('click');

        expect(Api.trackRedisHllUserEvent).not.toHaveBeenCalled();
      });
    });
  });
});
