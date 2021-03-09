import { GlIntersectionObserver, GlSkeletonLoading } from '@gitlab/ui';
import { createLocalVue, mount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import AlertFilters from 'ee/threat_monitoring/components/alerts/alert_filters.vue';
import AlertStatus from 'ee/threat_monitoring/components/alerts/alert_status.vue';
import AlertsList from 'ee/threat_monitoring/components/alerts/alerts_list.vue';
import { DEFAULT_FILTERS } from 'ee/threat_monitoring/components/alerts/constants';
import createMockApollo from 'helpers/mock_apollo_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import getAlertsQuery from '~/graphql_shared/queries/get_alerts.query.graphql';
import { defaultQuerySpy, emptyQuerySpy, loadingQuerySpy } from '../../mocks/mock_apollo';
import { mockAlerts, mockPageInfo } from '../../mocks/mock_data';

let localVue;

describe('AlertsList component', () => {
  let wrapper;
  const refetchSpy = jest.fn();
  const DEFAULT_PROJECT_PATH = '#';
  const DEFAULT_SORT = 'STARTED_AT_DESC';
  const PAGE_SIZE = 20;
  const defaultProps = { filters: DEFAULT_FILTERS };
  let querySpy;

  const createMockApolloProvider = (query) => {
    localVue.use(VueApollo);
    return createMockApollo([[getAlertsQuery, query]]);
  };

  const shallowApolloMock = {
    queries: {
      alerts: {
        fetchMore: jest.fn().mockResolvedValue(),
        loading: false,
        refetch: refetchSpy,
      },
    },
  };

  const findAlertFilters = () => wrapper.findComponent(AlertFilters);
  const findUnconfiguredAlert = () => wrapper.findByTestId('threat-alerts-unconfigured');
  const findErrorAlert = () => wrapper.findByTestId('threat-alerts-error');
  const findStartedAtColumn = () => wrapper.findByTestId('threat-alerts-started-at');
  const findStartedAtColumnHeader = () => wrapper.findByTestId('threat-alerts-started-at-header');
  const findIdColumn = () => wrapper.findByTestId('threat-alerts-id');
  const findEventCountColumn = () => wrapper.findByTestId('threat-alerts-event-count');
  const findStatusColumn = () => wrapper.findComponent(AlertStatus);
  const findStatusColumnHeader = () => wrapper.findByTestId('threat-alerts-status-header');
  const findEmptyState = () => wrapper.findByTestId('threat-alerts-empty-state');
  const findGlIntersectionObserver = () => wrapper.findComponent(GlIntersectionObserver);
  const findGlSkeletonLoading = () => wrapper.findComponent(GlSkeletonLoading);

  const createWrapper = ({ $apollo, apolloSpy = defaultQuerySpy, data, stubs = {} } = {}) => {
    let apolloOptions;
    if ($apollo) {
      apolloOptions = {
        mocks: {
          $apollo,
        },
        data,
      };
    } else {
      localVue = createLocalVue();
      querySpy = apolloSpy;
      const mockApollo = createMockApolloProvider(querySpy);
      apolloOptions = {
        localVue,
        apolloProvider: mockApollo,
      };
    }

    wrapper = extendedWrapper(
      mount(AlertsList, {
        propsData: defaultProps,
        provide: {
          documentationPath: '#',
          projectPath: DEFAULT_PROJECT_PATH,
        },
        stubs: {
          AlertStatus: true,
          AlertFilters: true,
          GlAlert: true,
          GlLoadingIcon: true,
          GlIntersectionObserver: true,
          ...stubs,
        },
        ...apolloOptions,
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('default state', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('shows threat monitoring alert filters', () => {
      expect(findAlertFilters().exists()).toBe(true);
    });

    it('does have the default filters initially', () => {
      expect(querySpy).toHaveBeenCalledTimes(1);
      expect(querySpy).toHaveBeenCalledWith(
        expect.objectContaining({
          firstPageSize: PAGE_SIZE,
          projectPath: DEFAULT_PROJECT_PATH,
          sort: DEFAULT_SORT,
          ...DEFAULT_FILTERS,
        }),
      );
    });

    it('does update its filters on filter event emitted', async () => {
      const newFilters = { statuses: [] };
      expect(wrapper.vm.filters).toEqual(DEFAULT_FILTERS);
      findAlertFilters().vm.$emit('filter-change', newFilters);
      await wrapper.vm.$nextTick();
      expect(wrapper.vm.filters).toEqual(newFilters);
    });

    it('does show all columns', () => {
      expect(findStartedAtColumn().exists()).toBe(true);
      expect(findIdColumn().exists()).toBe(true);
      expect(findEventCountColumn().exists()).toBe(true);
      expect(findStatusColumn().exists()).toBe(true);
    });

    it('does not show the empty state', () => {
      expect(findEmptyState().exists()).toBe(false);
    });

    it('does not show the unconfigured alert error state when the list is populated', () => {
      expect(findUnconfiguredAlert().exists()).toBe(false);
    });

    it('does not show the request error state', () => {
      expect(findErrorAlert().exists()).toBe(false);
    });

    it('does show the observer component', () => {
      expect(findGlIntersectionObserver().exists()).toBe(true);
    });

    it('does initially sort by started at, descending', () => {
      expect(wrapper.vm.sort).toBe('STARTED_AT_DESC');
      expect(findStartedAtColumnHeader().attributes('aria-sort')).toBe('descending');
    });

    it('updates sort with new direction and column key', async () => {
      expect(findStatusColumnHeader().attributes('aria-sort')).toBe('none');

      findStatusColumnHeader().trigger('click');
      await wrapper.vm.$nextTick();

      expect(wrapper.vm.sort).toBe('STATUS_DESC');
      expect(findStatusColumnHeader().attributes('aria-sort')).toBe('descending');

      findStatusColumnHeader().trigger('click');
      await wrapper.vm.$nextTick();

      expect(wrapper.vm.sort).toBe('STATUS_ASC');
      expect(findStatusColumnHeader().attributes('aria-sort')).toBe('ascending');
    });

    it('navigates to the alert details page on title click', () => {
      expect(findIdColumn().attributes('href')).toBe('/alerts/01');
    });
  });

  describe('empty state', () => {
    beforeEach(() => {
      createWrapper({ apolloSpy: emptyQuerySpy });
    });

    it('does show the empty state', () => {
      expect(findEmptyState().exists()).toBe(true);
    });

    it('does show the unconfigured alert error state when the list is empty', () => {
      expect(findUnconfiguredAlert().exists()).toBe(true);
    });
  });

  describe('loading state', () => {
    beforeEach(() => {
      createWrapper({ apolloSpy: loadingQuerySpy });
    });

    it('does show the loading state', () => {
      expect(findGlSkeletonLoading().exists()).toBe(true);
    });

    it('does not show all columns', () => {
      expect(findStartedAtColumn().exists()).toBe(false);
      expect(findIdColumn().exists()).toBe(false);
      expect(findStatusColumn().exists()).toBe(false);
    });

    it('does not show the empty state', () => {
      expect(findEmptyState().exists()).toBe(false);
    });
  });

  describe('error state', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('does not show the unconfigured alert error state when there is a request error', async () => {
      wrapper.setData({
        errored: true,
      });
      await wrapper.vm.$nextTick();
      expect(findErrorAlert().exists()).toBe(true);
      expect(findUnconfiguredAlert().exists()).toBe(false);
    });

    it('does not show the unconfigured alert error state when there is a request error that has been dismissed', async () => {
      wrapper.setData({
        isErrorAlertDismissed: true,
      });
      await wrapper.vm.$nextTick();
      expect(findUnconfiguredAlert().exists()).toBe(false);
    });
  });

  describe('loading more alerts', () => {
    it('does request more data', async () => {
      createWrapper({
        $apollo: shallowApolloMock,
        data: () => ({
          alerts: mockAlerts,
          pageInfo: mockPageInfo,
        }),
      });
      findGlIntersectionObserver().vm.$emit('appear');
      await wrapper.vm.$nextTick();
      expect(wrapper.vm.$apollo.queries.alerts.fetchMore).toHaveBeenCalledTimes(1);
    });
  });

  describe('changing alert status', () => {
    beforeEach(() => {
      createWrapper({
        $apollo: shallowApolloMock,
        data: () => ({
          alerts: mockAlerts,
          pageInfo: mockPageInfo,
        }),
      });
    });

    it('does refetch the alerts when an alert status has changed', async () => {
      expect(refetchSpy).toHaveBeenCalledTimes(0);
      findStatusColumn().vm.$emit('alert-update');
      await wrapper.vm.$nextTick();
      expect(refetchSpy).toHaveBeenCalledTimes(1);
    });

    it('does show an error if changing an alert status fails', async () => {
      const error = 'Error.';
      expect(findErrorAlert().exists()).toBe(false);
      findStatusColumn().vm.$emit('alert-error', error);
      await wrapper.vm.$nextTick();
      expect(findErrorAlert().exists()).toBe(true);
      expect(findErrorAlert().text()).toBe(error);
    });
  });
});
