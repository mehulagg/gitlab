import { shallowMount } from '@vue/test-utils';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import { trackAlertStatusUpdateOptions } from '~/alert_management/constants';
import AlertManagementStatus from '~/alert_management/components/alert_status.vue';
import updateAlertStatusMutation from '~/alert_management/graphql/mutations/update_alert_status.mutation.graphql';
import Tracking from '~/tracking';
import mockAlerts from '../mocks/alerts.json';

const mockAlert = mockAlerts[0];

describe('AlertManagementStatus', () => {
  let wrapper;
  const findStatusDropdown = () => wrapper.find(GlDropdown);
  const findFirstStatusOption = () => findStatusDropdown().find(GlDropdownItem);

  const selectFirstStatusOption = () => {
    findFirstStatusOption().vm.$emit('click');

    return waitForPromises();
  };

  function mountComponent({ props = {}, loading = false, stubs = {} } = {}) {
    wrapper = shallowMount(AlertManagementStatus, {
      propsData: {
        alert: { ...mockAlert },
        projectPath: 'gitlab-org/gitlab',
        isSidebar: false,
        ...props,
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
      mountComponent({});
    });

    it('calls `$apollo.mutate` with `updateAlertStatus` mutation and variables containing `iid`, `status`, & `projectPath`', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue(mockUpdatedMutationResult);
      findFirstStatusOption().vm.$emit('click');

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: updateAlertStatusMutation,
        variables: {
          iid,
          status: 'TRIGGERED',
          projectPath: 'gitlab-org/gitlab',
        },
      });
    });

    describe('when a request fails', () => {
      beforeEach(() => {
        jest.spyOn(wrapper.vm.$apollo, 'mutate').mockReturnValue(Promise.reject(new Error()));
      });

      it('emits an error', async () => {
        await selectFirstStatusOption();

        expect(wrapper.emitted('alert-error')[0]).toEqual([
          'There was an error while updating the status of the alert. Please try again.',
        ]);
      });

      it('emits an error when triggered a second time', async () => {
        await selectFirstStatusOption();
        await wrapper.vm.$nextTick();
        await selectFirstStatusOption();
        // Should emit two errors [0,1]
        expect(wrapper.emitted('alert-error').length > 1).toBe(true);
      });
    });

    it('shows an error when response includes HTML errors', async () => {
      const mockUpdatedMutationErrorResult = {
        data: {
          updateAlertStatus: {
            errors: ['<span data-testid="htmlError" />'],
            alert: {
              iid,
              status: 'acknowledged',
            },
          },
        },
      };

      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue(mockUpdatedMutationErrorResult);

      await selectFirstStatusOption();

      expect(wrapper.emitted('alert-error').length > 0).toBe(true);
      expect(wrapper.emitted('alert-error')[0]).toEqual([
        'There was an error while updating the status of the alert. <span data-testid="htmlError" />',
      ]);
    });
  });

  describe('Snowplow tracking', () => {
    beforeEach(() => {
      jest.spyOn(Tracking, 'event');
      mountComponent({});
    });

    it('should track alert status updates', () => {
      Tracking.event.mockClear();
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue({});
      findFirstStatusOption().vm.$emit('click');
      const status = findFirstStatusOption().text();
      setImmediate(() => {
        const { category, action, label } = trackAlertStatusUpdateOptions;
        expect(Tracking.event).toHaveBeenCalledWith(category, action, { label, property: status });
      });
    });
  });
});
