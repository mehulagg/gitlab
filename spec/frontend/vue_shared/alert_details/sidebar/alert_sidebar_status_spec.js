import { GlDropdown, GlDropdownItem, GlLoadingIcon } from '@gitlab/ui';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AlertStatus from '~/vue_shared/alert_details/components/alert_status.vue';
import AlertSidebarStatus from '~/vue_shared/alert_details/components/sidebar/sidebar_status.vue';
import { PAGE_CONFIG } from '~/vue_shared/alert_details/constants';
import mockAlerts from '../mocks/alerts.json';

const mockAlert = mockAlerts[0];

describe('Alert Details Sidebar Status', () => {
  let wrapper;
  const findStatusDropdown = () => wrapper.find(GlDropdown);
  const findStatusDropdownItem = () => wrapper.find(GlDropdownItem);
  const findStatusLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findAlertStatus = () => wrapper.findComponent(AlertStatus);
  const findStatus = () => wrapper.findByTestId('status');
  const findSidebarIcon = () => wrapper.findByTestId('status-icon');

  function mountComponent({
    data,
    sidebarCollapsed = true,
    loading = false,
    mount = shallowMountExtended,
    stubs = {},
    provide = {},
  } = {}) {
    wrapper = mount(AlertSidebarStatus, {
      propsData: {
        alert: { ...mockAlert },
        ...data,
        sidebarCollapsed,
        projectPath: 'projectPath',
      },
      mocks: {
        $apollo: {
          mutate: jest.fn(),
          queries: {
            alert: {
              loading,
            },
          },
        },
      },
      stubs,
      provide,
    });
  }

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('sidebar expanded', () => {
    beforeEach(() => {
      mountComponent({
        data: { alert: mockAlert },
        sidebarCollapsed: false,
        loading: false,
      });
    });

    it('displays status dropdown', () => {
      expect(findAlertStatus().exists()).toBe(true);
    });

    it('does not display the collapsed sidebar icon', () => {
      expect(findSidebarIcon().exists()).toBe(false);
    });

    describe('updating the alert status', () => {
      it('ensures dropdown is hidden when loading', async () => {
        mountComponent({
          data: { alert: mockAlert },
          sidebarCollapsed: false,
          loading: false,
          mount: mountExtended,
        });
        jest.spyOn(wrapper.vm.$apollo, 'mutate').mockReturnValue(new Promise(() => {}));
        findStatusDropdownItem().vm.$emit('click');
        await wrapper.vm.$nextTick();
        expect(findAlertStatus().classes('gl-display-none')).toBe(true);
        expect(findStatusLoadingIcon().exists()).toBe(true);
      });

      it('stops updating when the request fails', () => {
        mountComponent({
          data: { alert: mockAlert },
          sidebarCollapsed: false,
          loading: false,
          mount: shallowMountExtended,
        });
        findAlertStatus().vm.$emit('handle-updating', false);
        expect(findStatusLoadingIcon().exists()).toBe(false);
        expect(findStatus().text()).toBe('Triggered');
      });

      it('renders default translated statuses', () => {
        mountComponent({ sidebarCollapsed: false, mount: shallowMountExtended });
        expect(findAlertStatus().props('statuses')).toBe(PAGE_CONFIG.OPERATIONS.STATUSES);
        expect(findStatus().text()).toBe('Triggered');
      });

      it('emits "alert-update" when the status has been updated', () => {
        mountComponent({ sidebarCollapsed: false });
        expect(wrapper.emitted('alert-update')).toBeUndefined();
        findAlertStatus().vm.$emit('handle-updating');
        expect(wrapper.emitted('alert-update')).toEqual([[]]);
      });

      it('renders translated statuses', () => {
        const status = 'TEST';
        const statuses = { [status]: 'Test' };
        mountComponent({
          data: { alert: { ...mockAlert, status } },
          provide: { statuses },
          sidebarCollapsed: false,
          mount: shallowMountExtended,
        });
        expect(findAlertStatus().props('statuses')).toBe(statuses);
        expect(findStatus().text()).toBe(statuses.TEST);
      });
    });
  });

  describe('sidebar collapsed', () => {
    beforeEach(() => {
      mountComponent({
        data: { alert: mockAlert },
        loading: false,
      });
    });
    it('does not display the status dropdown', () => {
      expect(findStatusDropdown().exists()).toBe(false);
    });

    it('does display the collapsed sidebar icon', () => {
      expect(findSidebarIcon().exists()).toBe(true);
    });
  });
});
