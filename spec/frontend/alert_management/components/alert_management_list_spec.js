import { mount } from '@vue/test-utils';
import {
  GlEmptyState,
  GlTable,
  GlAlert,
  GlLoadingIcon,
  GlDropdown,
  GlIcon,
  GlTab,
  GlDropdownItem,
} from '@gitlab/ui';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import createFlash from '~/flash';
import AlertManagementList from '~/alert_management/components/alert_management_list.vue';
import { ALERTS_STATUS_TABS } from '../../../../app/assets/javascripts/alert_management/constants';
import updateAlertStatus from '~/alert_management/graphql/mutations/update_alert_status.graphql';
import mockAlerts from '../mocks/alerts.json';

jest.mock('~/flash');

describe('AlertManagementList', () => {
  let wrapper;

  const findAlertsTable = () => wrapper.find(GlTable);
  const findAlerts = () => wrapper.findAll('table tbody tr');
  const findAlert = () => wrapper.find(GlAlert);
  const findLoader = () => wrapper.find(GlLoadingIcon);
  const findStatusDropdown = () => wrapper.find(GlDropdown);
  const findStatusFilterTabs = () => wrapper.findAll(GlTab);
  const findDateFields = () => wrapper.findAll(TimeAgo);
  const findFirstStatusOption = () => findStatusDropdown().find(GlDropdownItem);
  const findSeverityFields = () => wrapper.findAll('[data-testid="severityField"]');

  function mountComponent({
    props = {
      alertManagementEnabled: false,
      userCanEnableAlertManagement: false,
    },
    data = {},
    loading = false,
    alertListStatusFilteringEnabled = false,
    stubs = {},
  } = {}) {
    wrapper = mount(AlertManagementList, {
      propsData: {
        projectPath: 'gitlab-org/gitlab',
        enableAlertManagementPath: '/link',
        emptyAlertSvgPath: 'illustration/path',
        ...props,
      },
      provide: {
        glFeatures: { alertListStatusFilteringEnabled },
      },
      data() {
        return data;
      },
      mocks: {
        $apollo: {
          mutate: jest.fn(),
          queries: {
            alerts: {
              loading,
            },
          },
        },
      },
      stubs,
    });
  }

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('alert management feature renders empty state', () => {
    it('shows empty state', () => {
      expect(wrapper.find(GlEmptyState).exists()).toBe(true);
    });
  });

  describe('Status Filter Tabs', () => {
    describe('alertListStatusFilteringEnabled feature flag enabled', () => {
      beforeEach(() => {
        mountComponent({
          props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
          data: { alerts: mockAlerts },
          loading: false,
          alertListStatusFilteringEnabled: true,
          stubs: {
            GlTab: true,
          },
        });
      });

      it('should display filter tabs for all statuses', () => {
        const tabs = findStatusFilterTabs().wrappers;
        tabs.forEach((tab, i) => {
          expect(tab.text()).toContain(ALERTS_STATUS_TABS[i].title);
        });
      });
    });

    describe('alertListStatusFilteringEnabled feature flag disabled', () => {
      beforeEach(() => {
        mountComponent({
          props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
          data: { alerts: mockAlerts },
          loading: false,
          alertListStatusFilteringEnabled: false,
          stubs: {
            GlTab: true,
          },
        });
      });

      it('should NOT display tabs', () => {
        expect(findStatusFilterTabs()).not.toExist();
      });
    });
  });

  describe('Alerts table', () => {
    it('loading state', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: null },
        loading: true,
      });
      expect(findAlertsTable().exists()).toBe(true);
      expect(findLoader().exists()).toBe(true);
    });

    it('error state', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: null, errored: true },
        loading: false,
      });
      expect(findAlertsTable().exists()).toBe(true);
      expect(findAlertsTable().text()).toContain('No alerts to display');
      expect(findLoader().exists()).toBe(false);
      expect(findAlert().props().variant).toBe('danger');
    });

    it('empty state', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: [], errored: false },
        loading: false,
      });
      expect(findAlertsTable().exists()).toBe(true);
      expect(findAlertsTable().text()).toContain('No alerts to display');
      expect(findLoader().exists()).toBe(false);
      expect(findAlert().props().variant).toBe('info');
    });

    it('has data state', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: mockAlerts, errored: false },
        loading: false,
      });
      expect(findLoader().exists()).toBe(false);
      expect(findAlertsTable().exists()).toBe(true);
      expect(findAlerts()).toHaveLength(mockAlerts.length);
    });

    it('displays status dropdown', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: mockAlerts, errored: false },
        loading: false,
      });
      expect(findStatusDropdown().exists()).toBe(true);
    });

    it('shows correct severity icons', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: mockAlerts, errored: false },
        loading: false,
      });

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.find(GlTable).exists()).toBe(true);
        expect(
          findAlertsTable()
            .find(GlIcon)
            .classes('icon-critical'),
        ).toBe(true);
      });
    });

    it('renders severity text', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: mockAlerts, errored: false },
        loading: false,
      });

      expect(
        findSeverityFields()
          .at(0)
          .text(),
      ).toBe('Critical');
    });

    describe('handle date fields', () => {
      it('should display time ago dates when values provided', () => {
        mountComponent({
          props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
          data: {
            alerts: [
              {
                iid: 1,
                status: 'acknowledged',
                startedAt: '2020-03-17T23:18:14.996Z',
                endedAt: '2020-04-17T23:18:14.996Z',
                severity: 'high',
              },
            ],
            errored: false,
          },
          loading: false,
        });
        expect(findDateFields().length).toBe(2);
      });

      it('should not display time ago dates when values not provided', () => {
        mountComponent({
          props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
          data: {
            alerts: [
              {
                iid: 1,
                status: 'acknowledged',
                startedAt: null,
                endedAt: null,
                severity: 'high',
              },
            ],
            errored: false,
          },
          loading: false,
        });
        expect(findDateFields().exists()).toBe(false);
      });
    });
  });

  describe('updating the alert status', () => {
    const iid = '1527542';
    const mockUpdatedMutationResult = {
      data: {
        updateAlertStatus: {
          errors: [],
          alert: {
            iid,
            status: 'acknowledged',
          },
        },
      },
    };

    beforeEach(() => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: mockAlerts, errored: false },
        loading: false,
      });
    });

    it('calls `$apollo.mutate` with `updateAlertStatus` mutation and variables containing `iid`, `status`, & `projectPath`', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue(mockUpdatedMutationResult);
      findFirstStatusOption().vm.$emit('click');

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: updateAlertStatus,
        variables: {
          iid,
          status: 'TRIGGERED',
          projectPath: 'gitlab-org/gitlab',
        },
      });
    });

    it('calls `createFlash` when request fails', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockReturnValue(Promise.reject(new Error()));
      findFirstStatusOption().vm.$emit('click');

      setImmediate(() => {
        expect(createFlash).toHaveBeenCalledWith(
          'There was an error while updating the status of the alert. Please try again.',
        );
      });
    });
  });
});
