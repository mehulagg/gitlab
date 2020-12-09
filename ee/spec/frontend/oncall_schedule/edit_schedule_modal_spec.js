import { shallowMount, createLocalVue } from '@vue/test-utils';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import { GlModal, GlAlert } from '@gitlab/ui';
import VueApollo from 'vue-apollo';
import waitForPromises from 'helpers/wait_for_promises';
import getOncallSchedulesQuery from 'ee/oncall_schedules/graphql/queries/get_oncall_schedules.query.graphql';
import updateOncallScheduleMutation from 'ee/oncall_schedules/graphql/mutations/update_oncall_schedule.mutation.graphql';
import UpdateScheduleModal, { i18n } from 'ee/oncall_schedules/components/edit_schedule_modal.vue';
import {
  getOncallSchedulesQueryResponse,
  updateScheduleResponse,
  updateScheduleResponseWithErrors,
} from './mocks/apollo_mock';
import mockTimezones from './mocks/mockTimezones.json';

const localVue = createLocalVue();
const projectPath = 'group/project';
const mutate = jest.fn();
const mockHideModal = jest.fn();
const schedule =
  getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0];

localVue.use(VueApollo);

describe('UpdateScheduleModal', () => {
  let wrapper;
  let fakeApollo;
  let updateScheduleHandler;

  const findModal = () => wrapper.find(GlModal);
  const findAlert = () => wrapper.find(GlAlert);

  async function awaitApolloDomMock() {
    await wrapper.vm.$nextTick(); // kick off the DOM update
    await jest.runOnlyPendingTimers(); // kick off the mocked GQL stuff (promises)
    await wrapper.vm.$nextTick(); // kick off the DOM update for flash
  }

  async function updateSchedule(localWrapper) {
    await jest.runOnlyPendingTimers();
    await localWrapper.vm.$nextTick();

    localWrapper.find(GlModal).vm.$emit('primary', { preventDefault: jest.fn() });
  }

  const createComponent = ({ data = {}, props = {} } = {}) => {
    wrapper = shallowMount(UpdateScheduleModal, {
      data() {
        return {
          ...data,
          form: schedule,
        };
      },
      propsData: {
        schedule,
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

    const requestHandlers = [
      [getOncallSchedulesQuery, jest.fn().mockResolvedValue(getOncallSchedulesQueryResponse)],
      [updateOncallScheduleMutation, updateScheduleHandler],
    ];

    fakeApollo = createMockApollo(requestHandlers);

    fakeApollo.clients.defaultClient.cache.writeQuery({
      query: getOncallSchedulesQuery,
      variables: {
        projectPath: 'group/project',
      },
      data: getOncallSchedulesQueryResponse.data,
    });

    wrapper = shallowMount(UpdateScheduleModal, {
      localVue,
      apolloProvider: fakeApollo,
      data() {
        return {
          form: schedule,
        };
      },
      propsData: {
        schedule,
      },
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
        variables: {
          iid: schedule.iid,
          projectPath,
          name: schedule.name,
          description: schedule.description,
          timezone: schedule.timezone.identifier,
        },
      });
    });

    it('hides the modal on successful schedule creation', async () => {
      mutate.mockResolvedValueOnce({ data: { oncallScheduleUpdate: { errors: [] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      expect(mockHideModal).toHaveBeenCalled();
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
    it('has the name of the schedule to update based on getOncallSchedulesQuery', async () => {
      createComponentWithApollo();

      await jest.runOnlyPendingTimers();
      await wrapper.vm.$nextTick();

      expect(findModal().attributes('data-testid')).toBe(`update-schedule-modal-${schedule.iid}`);
    });

    it('calls a mutation with correct parameters and updates a schedule', async () => {
      createComponentWithApollo();

      await updateSchedule(wrapper);

      expect(updateScheduleHandler).toHaveBeenCalled();
    });

    it('displays alert if mutation had a recoverable error', async () => {
      createComponentWithApollo({
        updateHandler: jest.fn().mockResolvedValue(updateScheduleResponseWithErrors),
      });

      await updateSchedule(wrapper);
      await awaitApolloDomMock();

      const alert = findAlert();
      expect(alert.exists()).toBe(true);
      expect(alert.text()).toContain('Houston, we have a problem');
    });
  });
});
