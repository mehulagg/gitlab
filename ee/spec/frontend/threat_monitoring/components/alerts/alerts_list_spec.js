import { GlIntersectionObserver, GlSkeletonLoading } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import AlertsList from 'ee/threat_monitoring/components/alerts/alerts_list.vue';
import AlertStatus from 'ee/threat_monitoring/components/alerts/alert_status.vue';
import { mockAlerts } from '../../mock_data';

const alerts = mockAlerts;

const pageInfo = {
  endCursor: 'eyJpZCI6IjIwIiwic3RhcnRlZF9hdCI6IjIwMjAtMTItMDMgMjM6MTI6NDkuODM3Mjc1MDAwIFVUQyJ9',
  hasNextPage: true,
  hasPreviousPage: false,
  startCursor: 'eyJpZCI6IjM5Iiwic3RhcnRlZF9hdCI6IjIwMjAtMTItMDQgMTg6MDE6MDcuNzY1ODgyMDAwIFVUQyJ9',
};

describe('AlertsList component', () => {
  let wrapper;
  const refetchSpy = jest.fn();
  const apolloMock = {
    queries: {
      alerts: {
        fetchMore: jest.fn().mockResolvedValue(),
        loading: false,
        refetch: refetchSpy,
      },
    },
  };

  const findUnconfiguredAlert = () => wrapper.find("[data-testid='threat-alerts-unconfigured']");
  const findErrorAlert = () => wrapper.find("[data-testid='threat-alerts-error']");
  const findStartedAtColumn = () => wrapper.find("[data-testid='threat-alerts-started-at']");
  const findStartedAtColumnHeader = () =>
    wrapper.find("[data-testid='threat-alerts-started-at-header']");
  const findIdColumn = () => wrapper.find("[data-testid='threat-alerts-id']");
  const findStatusColumn = () => wrapper.find(AlertStatus);
  const findStatusColumnHeader = () => wrapper.find("[data-testid='threat-alerts-status-header']");
  const findEmptyState = () => wrapper.find("[data-testid='threat-alerts-empty-state']");
  const findGlIntersectionObserver = () => wrapper.find(GlIntersectionObserver);
  const findGlSkeletonLoading = () => wrapper.find(GlSkeletonLoading);

  const createWrapper = ({ $apollo = apolloMock, data = {}, stubs = {} } = {}) => {
    wrapper = mount(AlertsList, {
      mocks: {
        $apollo,
      },
      provide: {
        documentationPath: '#',
        projectPath: '#',
      },
      stubs: {
        AlertStatus: true,
        GlAlert: true,
        GlLoadingIcon: true,
        GlIntersectionObserver: true,
        ...stubs,
      },
      data() {
        return data;
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('default state', () => {
    beforeEach(() => {
      createWrapper({ data: { alerts, pageInfo } });
    });

    it('does show all columns', () => {
      expect(findStartedAtColumn().exists()).toBe(true);
      expect(findIdColumn().exists()).toBe(true);
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
  });

  describe('empty state', () => {
    beforeEach(() => {
      createWrapper({ data: { alerts: [] } });
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
      const apolloMockLoading = {
        queries: { alerts: { loading: true } },
      };
      createWrapper({ $apollo: apolloMockLoading });
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
        data: {
          alerts,
          pageInfo,
        },
      });
      findGlIntersectionObserver().vm.$emit('appear');
      await wrapper.vm.$nextTick();
      expect(wrapper.vm.$apollo.queries.alerts.fetchMore).toHaveBeenCalledTimes(1);
    });
  });

  describe('changing alert status', () => {
    beforeEach(() => {
      createWrapper();
      wrapper.setData({
        alerts,
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
