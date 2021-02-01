import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { shallowMount } from '@vue/test-utils';
import { GlSprintf, GlModal, GlFormGroup, GlFormCheckbox } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import httpStatus from '~/lib/utils/http_status';
import CustomNotificationsModal from '~/notifications/components/custom_notifications_modal.vue';
import { i18n } from '~/notifications/constants';

const mockNotificationSettingsResponse = {
  level: 'custom',
  events: {
    change_reviewer_merge_request: null,
    close_issue: null,
    close_merge_request: null,
    failed_pipeline: true,
    fixed_pipeline: true,
    issue_due: null,
    merge_merge_request: null,
    moved_project: true,
    new_epic: false,
    new_issue: null,
    new_merge_request: null,
    new_note: true,
    new_release: true,
    push_to_merge_request: null,
    reassign_issue: null,
    reassign_merge_request: null,
    reopen_issue: null,
    reopen_merge_request: null,
    success_pipeline: null,
  },
};

describe('CustomNotificationsModal', () => {
  let wrapper;
  let mockAxios;

  function createComponent(options = {}) {
    const { injectedProperties = {}, props = {} } = options;
    return shallowMount(CustomNotificationsModal, {
      props: {
        ...props,
      },
      provide: {
        ...injectedProperties,
      },
      stubs: {
        GlModal,
        GlFormGroup,
        GlFormCheckbox,
      },
    });
  }

  const findByTestId = (testId) => wrapper.find(`[data-testid="${testId}"]`);
  const findModalBodyDescription = () => wrapper.find(GlSprintf);
  const findAllCheckboxes = () => wrapper.findAll(GlFormCheckbox);
  const findCheckboxAt = (index) => findAllCheckboxes().at(index);

  beforeEach(() => {
    gon.api_version = 'v4';
    mockAxios = new MockAdapter(axios);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    mockAxios.restore();
  });

  describe('template', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('renders the body title and the body message', () => {
      expect(findByTestId('modalBodyTitle').text()).toEqual(
        i18n.customNotificationsModal.bodyTitle,
      );
      expect(findModalBodyDescription().attributes('message')).toContain(
        i18n.customNotificationsModal.bodyMessage,
      );
    });

    xit('renders the dropdown items', () => {
      // TODO
    });
  });

  describe('API calls', () => {
    beforeEach(() => {
      jest.spyOn(axios, 'get');
    });

    it.each`
      projectId | groupId | endpointUrl                                   | endpointType               | condition
      ${1}      | ${null} | ${'/api/v4/projects/1/notification_settings'} | ${'project notifications'} | ${'a projectId is given'}
      ${null}   | ${1}    | ${'/api/v4/groups/1/notification_settings'}   | ${'group notifications'}   | ${'a groupId is given'}
      ${null}   | ${null} | ${'/api/v4/notification_settings'}            | ${'global notifications'}  | ${'when neither projectId nor groupId are given'}
    `(
      'calls the $endpointType endpoint when $condition',
      async ({ projectId, groupId, endpointUrl }) => {
        const injectedProperties = {
          projectId,
          groupId,
        };

        mockAxios.onGet(endpointUrl).reply(httpStatus.OK, mockNotificationSettingsResponse);

        wrapper = createComponent({ injectedProperties });

        // wrapper.vm.onOpen();

        wrapper.find(GlModal).vm.$emit('show');

        await waitForPromises();

        expect(axios.get).toHaveBeenCalledWith(endpointUrl);
      },
    );

    it('updates the loading state and the events property', async () => {
      const endpointUrl = '/api/v4/notification_settings';

      mockAxios.onGet(endpointUrl).reply(httpStatus.OK, mockNotificationSettingsResponse);

      wrapper = createComponent();

      wrapper.find(GlModal).vm.$emit('show');
      expect(wrapper.vm.isLoading).toBe(true);

      await waitForPromises();

      expect(axios.get).toHaveBeenCalledWith(endpointUrl);
      expect(wrapper.vm.isLoading).toBe(false);
    });

    it('updates the notification setting when a user clicks the checkbox', async () => {
      const endpointUrl = '/api/v4/notification_settings';

      jest.spyOn(axios, 'put');
      mockAxios.onPut(endpointUrl).reply(httpStatus.OK, mockNotificationSettingsResponse);

      wrapper = createComponent();

      wrapper.setData({
        events: [
          { id: 'new_release', enabled: true, name: 'New release', loading: false },
          { id: 'new_note', enabled: false, name: 'New note', loading: false },
        ],
      });

      await wrapper.vm.$nextTick();

      findCheckboxAt(1).vm.$emit('change', true);

      await waitForPromises();

      expect(axios.put).toHaveBeenCalledWith(endpointUrl, {
        new_note: true,
      });
    });
  });
});
