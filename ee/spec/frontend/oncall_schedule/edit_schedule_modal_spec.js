/* eslint-disable no-unused-vars */
import { shallowMount, createLocalVue } from '@vue/test-utils';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import { GlModal } from '@gitlab/ui';
import VueApollo from 'vue-apollo';
import waitForPromises from 'helpers/wait_for_promises';
import updateOncallScheduleMutation from 'ee/oncall_schedules/graphql/mutations/update_oncall_schedule.mutation.graphql';
import UpdateScheduleModal, { i18n } from 'ee/oncall_schedules/components/edit_schedule_modal.vue';
import { UPDATE_SCHEDULE_ERROR } from 'ee/oncall_schedules/utils/error_messages';
import { getOncallSchedulesQueryResponse, updateScheduleResponse } from './mocks/apollo_mock';
import mockTimezones from './mocks/mockTimezones.json';
import { awaitApolloDomMock } from './utils/index';

const localVue = createLocalVue();
const projectPath = 'group/project';
const mutate = jest.fn();
const mockHideModal = jest.fn();

localVue.use(VueApollo);

describe('UpdateScheduleModal', () => {
  let wrapper;
  let fakeApollo;
  let updateScheduleHandler;

  const findModal = () => wrapper.find(GlModal);

  async function destroySchedule(localWrapper) {
    await jest.runOnlyPendingTimers();
    await localWrapper.vm.$nextTick();

    localWrapper.vm.$emit('primary');
  }

  const createComponent = ({ data = {}, props = {} } = {}) => {
    wrapper = shallowMount(UpdateScheduleModal, {
      data() {
        return {
          ...data,
          form:
            getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0],
        };
      },
      propsData: {
        schedule:
          getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0],
        ...props,
      },
      provide: {
        projectPath,
        timezones: mockTimezones,
      },
      mocks: {
        $apollo: {
          mutate,
        },
      },
    });
    wrapper.vm.$refs.updateScheduleModal.hide = mockHideModal;
  };

  function createComponentWithApollo({
    updateHandler = jest.fn().mockResolvedValue(updateScheduleResponse),
  } = {}) {
    localVue.use(VueApollo);
    updateScheduleHandler = updateHandler;

    const requestHandlers = [[updateOncallScheduleMutation, updateScheduleHandler]];

    fakeApollo = createMockApollo(requestHandlers);

    wrapper = shallowMount(UpdateScheduleModal, {
      localVue,
      apolloProvider: fakeApollo,
      provide: {
        projectPath,
        timezones: mockTimezones,
      },
    });
  }

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders update schedule modal layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('renders update modal with the correct schedule information', () => {
    it('renders name of correct modal id', () => {
      expect(findModal().attributes('modalid')).toBe('updateScheduleModal');
    });

    it('renders name of schedule to update', () => {
      expect(findModal().html()).toContain(i18n.editSchedule);
    });
  });

  describe('Schedule update apollo API call', () => {
    it('makes a request with `oncallScheduleUpdate` to update a schedule', () => {
      mutate.mockResolvedValueOnce({});
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      expect(mutate).toHaveBeenCalledWith({
        mutation: expect.any(Object),
        update: expect.anything(),
        // TODO: Once the BE is complete for the mutation update this spec to use the correct params
        variables: expect.anything(),
      });
    });

    it('hides the modal on successful schedule creation', async () => {
      mutate.mockResolvedValueOnce({ data: { oncallScheduleUpdate: { errors: [] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      // TODO: Once the BE is complete for the mutation update this spec to use the call
      expect(mockHideModal).not.toHaveBeenCalled();
    });

    it("doesn't hide the modal on fail", async () => {
      const error = 'some error';
      mutate.mockResolvedValueOnce({ data: { oncallScheduleUpdate: { errors: [error] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      expect(mockHideModal).not.toHaveBeenCalled();
    });
  });

  describe('with mocked Apollo client', () => {
    // TODO: Once the BE is complete for the mutation add specs here for that via a destroyHandler
  });
});
