import { GlLoadingIcon } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import AlertsList from 'ee/threat_monitoring/components/alerts/alerts_list.vue';

const alerts = {
  list: [
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
  ],
  pageInfo: {},
};

describe('AlertsList component', () => {
  let wrapper;
  const apolloMock = {
    queries: { alerts: { loading: false } },
  };

  const findUnconfiguredAlert = () => wrapper.find("[data-testid='threat-alerts-unconfigured']");
  const findErrorAlert = () => wrapper.find("[data-testid='threat-alerts-error']");
  const findStartedAtColumn = () => wrapper.find("[data-testid='threat-alerts-started-at']");
  const findIdColumn = () => wrapper.find("[data-testid='threat-alerts-id']");
  const findStatusColumnHeader = () => wrapper.find("[data-testid='threat-alerts-status-header']");
  const findStatusColumn = () => wrapper.find("[data-testid='threat-alerts-status']");
  const findEmptyState = () => wrapper.find("[data-testid='threat-alerts-empty-state']");
  const findGlLoadingIcon = () => wrapper.find(GlLoadingIcon);

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

    it('is initially sorted by started at, descending', () => {
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
    beforeEach(() => {
      createWrapper();
    });

    it('does show the empty state', () => {
      expect(findEmptyState().exists()).toBe(true);
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
      expect(findGlLoadingIcon().exists()).toBe(true);
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

  describe('error states', () => {
    it('does show the unconfigured alert error state', async () => {
      createWrapper();
      wrapper.setData({
        alerts: { list: [] },
      });
      await wrapper.vm.$nextTick();
      expect(findUnconfiguredAlert().exists()).toBe(true);
    });

    it('does show the request alerts error state', async () => {
      createWrapper();
      wrapper.setData({
        errored: true,
      });
      await wrapper.vm.$nextTick();
      expect(findErrorAlert().exists()).toBe(true);
    });
  });
});
