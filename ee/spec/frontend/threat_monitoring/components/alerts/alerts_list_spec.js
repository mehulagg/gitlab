import { GlLoadingIcon } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import AlertsList from 'ee/threat_monitoring/components/alerts/alerts_list.vue';
import AlertStatus from 'ee/threat_monitoring/components/alerts/alert_status.vue';
import { mockAlerts } from '../../mock_data';

const alerts = {
  list: mockAlerts,
  pageInfo: {},
};

describe('AlertsList component', () => {
  let wrapper;
  const refetchSpy = jest.fn();
  const apolloMock = {
    queries: { alerts: { loading: false, refetch: refetchSpy } },
  };

  const findUnconfiguredAlert = () => wrapper.find("[data-testid='threat-alerts-unconfigured']");
  const findErrorAlert = () => wrapper.find("[data-testid='threat-alerts-error']");
  const findStartedAtColumn = () => wrapper.find("[data-testid='threat-alerts-started-at']");
  const findIdColumn = () => wrapper.find("[data-testid='threat-alerts-id']");
  const findStatusColumnHeader = () => wrapper.find("[data-testid='threat-alerts-status-header']");
  const findStatusColumn = () => wrapper.find(AlertStatus);
  const findEmptyState = () => wrapper.find("[data-testid='threat-alerts-empty-state']");
  const findGlLoadingIcon = () => wrapper.find(GlLoadingIcon);

  const createWrapper = ({ $apollo = apolloMock, stubs = {} } = {}) => {
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
        ...stubs,
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

    it('does not show the unconfigured alert error state when the list is populated', async () => {
      expect(findUnconfiguredAlert().exists()).toBe(false);
    });

    it('does not show the request error state', async () => {
      expect(findErrorAlert().exists()).toBe(false);
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
    beforeEach(async () => {
      createWrapper();
      wrapper.setData({
        alerts: { list: [] },
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

  describe('changing alert status', () => {
    beforeEach(() => {
      createWrapper();
      wrapper.setData({
        alerts,
      });
    });

    it('does refetch the alerts when an alert status has changed', async () => {
      expect(refetchSpy).toHaveBeenCalledTimes(0);
      findStatusColumn().vm.$emit('hide-dropdown');
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
