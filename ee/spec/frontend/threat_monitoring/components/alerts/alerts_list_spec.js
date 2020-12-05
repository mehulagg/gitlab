import { GlIntersectionObserver, GlSkeletonLoading } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import AlertsList from 'ee/threat_monitoring/components/alerts/alerts_list.vue';

const alerts = [
  {
    iid: '01',
    title: 'Issue 01',
    status: 'TRIGGERED',
    startedAt: '2020-11-19T18:36:23Z',
  },
  {
    iid: '02',
    title: 'Issue 02',
    status: 'ACKNOWLEDGED',
    startedAt: '2020-11-16T21:59:28Z',
  },
  {
    iid: '03',
    title: 'Issue 03',
    status: 'RESOLVED',
    startedAt: '2020-11-13T20:03:04Z',
  },
  {
    iid: '04',
    title: 'Issue 04',
    status: 'IGNORED',
    startedAt: '2020-10-29T13:37:55Z',
  },
];

const pageInfo = {
  endCursor: 'eyJpZCI6IjIwIiwic3RhcnRlZF9hdCI6IjIwMjAtMTItMDMgMjM6MTI6NDkuODM3Mjc1MDAwIFVUQyJ9',
  hasNextPage: true,
  hasPreviousPage: false,
  startCursor: 'eyJpZCI6IjM5Iiwic3RhcnRlZF9hdCI6IjIwMjAtMTItMDQgMTg6MDE6MDcuNzY1ODgyMDAwIFVUQyJ9',
};

describe('AlertsList component', () => {
  let wrapper;
  const apolloMock = {
    queries: {
      alerts: {
        fetchMore: jest.fn().mockResolvedValue(),
        loading: false,
      },
    },
  };

  const findUnconfiguredAlert = () => wrapper.find("[data-testid='threat-alerts-unconfigured']");
  const findErrorAlert = () => wrapper.find("[data-testid='threat-alerts-error']");
  const findStartedAtColumn = () => wrapper.find("[data-testid='threat-alerts-started-at']");
  const findIdColumn = () => wrapper.find("[data-testid='threat-alerts-id']");
  const findStatusColumnHeader = () => wrapper.find("[data-testid='threat-alerts-status-header']");
  const findStatusColumn = () => wrapper.find("[data-testid='threat-alerts-status']");
  const findEmptyState = () => wrapper.find("[data-testid='threat-alerts-empty-state']");
  const findGlIntersectionObserver = () => wrapper.find(GlIntersectionObserver);
  const findGlSkeletonLoading = () => wrapper.find(GlSkeletonLoading);

  const createWrapper = ({ $apollo = apolloMock } = {}) => {
    wrapper = mount(AlertsList, {
      mocks: {
        $apollo,
      },
      provide: {
        documentationPath: '#',
        projectPath: '#',
      },
      stubs: {
        GlAlert: true,
        GlLoadingIcon: true,
        GlIntersectionObserver: true,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('default state', () => {
    beforeEach(() => {
      createWrapper();
      wrapper.setData({
        alerts,
        pageInfo,
      });
    });

    it('does show all columns', () => {
      expect(findStartedAtColumn().exists()).toBe(true);
      expect(findIdColumn().exists()).toBe(true);
      expect(findStatusColumn().exists()).toBe(true);
    });

    it('does not show the empty state', () => {
      expect(findEmptyState().exists()).toBe(false);
    });

    it('does not show the unconfigured alert error state when the list is populated', async () => {
      expect(findUnconfiguredAlert().exists()).toBe(false);
    });

    it('does not show the request error state', async () => {
      expect(findErrorAlert().exists()).toBe(false);
    });

    it('does show the observer component', () => {
      expect(findGlIntersectionObserver().exists()).toBe(true);
    });

    it('does initially sort by started at, descending', () => {
      expect(wrapper.vm.sort).toBe('STARTED_AT_DESC');
    });

    it('updates sort with new direction and column key', () => {
      findStatusColumnHeader().trigger('click');

      expect(wrapper.vm.$data.sort).toBe('STATUS_DESC');

      findStatusColumnHeader().trigger('click');

      expect(wrapper.vm.$data.sort).toBe('STATUS_ASC');
    });
  });

  describe('empty state', () => {
    beforeEach(async () => {
      createWrapper();
      wrapper.setData({
        alerts: [],
      });
    });

    it('does show the empty state', () => {
      expect(findEmptyState().exists()).toBe(true);
    });

    it('does show the unconfigured alert error state when the list is empty', async () => {
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
      createWrapper();
      wrapper.setData({
        alerts,
        pageInfo,
      });
      await wrapper.vm.$nextTick();
      findGlIntersectionObserver().vm.$emit('appear');
      await wrapper.vm.$nextTick();
      expect(wrapper.vm.$apollo.queries.alerts.fetchMore).toHaveBeenCalledTimes(1);
    });
  });
});
