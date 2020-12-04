/* eslint-disable no-unused-vars */
import { shallowMount, createLocalVue } from '@vue/test-utils';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import { GlModal, GlAlert, GlSprintf } from '@gitlab/ui';
import VueApollo from 'vue-apollo';
import waitForPromises from 'helpers/wait_for_promises';
import destroyOncallScheduleMutation from 'ee/oncall_schedules/graphql/mutations/destroy_oncall_schedule.mutation.graphql';
import DeleteScheduleModal, {
  i18n,
} from 'ee/oncall_schedules/components/delete_schedule_modal.vue';
import { getOncallSchedulesQueryResponse, destroyScheduleResponse } from './mocks/apollo_mock';

const localVue = createLocalVue();
const projectPath = 'group/project';
const mutate = jest.fn();
const mockHideModal = jest.fn();

localVue.use(VueApollo);

describe('DeleteScheduleModal', () => {
  let wrapper;
  let fakeApollo;
  let destroyScheduleHandler;

  const findModal = () => wrapper.find(GlModal);
  const findModalText = () => wrapper.find(GlSprintf);
  const findAlert = () => wrapper.find(GlAlert);

  async function awaitApolloDomMock() {
    await wrapper.vm.$nextTick(); // kick off the DOM update
    await jest.runOnlyPendingTimers(); // kick off the mocked GQL stuff (promises)
    await wrapper.vm.$nextTick(); // kick off the DOM update for flash
  }

  async function destroySchedule(localWrapper) {
    await jest.runOnlyPendingTimers();
    await localWrapper.vm.$nextTick();

    localWrapper.vm.$emit('primary');
  }

  const createComponent = ({ data = {}, props = {} } = {}) => {
    wrapper = shallowMount(DeleteScheduleModal, {
      data() {
        return {
          ...data,
        };
      },
      propsData: {
        schedule:
          getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0],
        ...props,
      },
      provide: {
        projectPath,
      },
      mocks: {
        $apollo: {
          mutate,
        },
      },
      stubs: { GlSprintf: false },
    });
    wrapper.vm.$refs.deleteScheduleModal.hide = mockHideModal;
  };

  function createComponentWithApollo({
    destroyHandler = jest.fn().mockResolvedValue(destroyScheduleResponse),
  } = {}) {
    localVue.use(VueApollo);
    destroyScheduleHandler = destroyHandler;

    const requestHandlers = [[destroyOncallScheduleMutation, destroyScheduleHandler]];

    fakeApollo = createMockApollo(requestHandlers);

    wrapper = shallowMount(DeleteScheduleModal, {
      localVue,
      apolloProvider: fakeApollo,
      provide: {
        projectPath,
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

  it('renders delete schedule modal layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('renders delete modal with the correct schedule information', () => {
    it('renders name of schedule to destroy', () => {
      expect(findModalText().attributes('message')).toBe(i18n.deleteScheduleMessage);
    });
  });

  describe('Schedule destroy apollo API call', () => {
    it('makes a request with `oncallScheduleDestroy` to delete a schedule', () => {
      mutate.mockResolvedValueOnce({});
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      expect(mutate).toHaveBeenCalledWith({
        mutation: expect.any(Object),
        update: expect.anything(),
        // TODO: Once the BE is complete for the mutation update this spec to use the correct params
        variables: expect.anything(),
      });
    });

    it('hides the modal on successful schedule deletion', async () => {
      mutate.mockResolvedValueOnce({ data: { oncallScheduleDestroy: { errors: [] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      expect(mockHideModal).toHaveBeenCalled();
    });

    it("doesn't hide the modal on deletion fail", async () => {
      const error = 'some error';
      mutate.mockResolvedValueOnce({ data: { oncallScheduleDestroy: { errors: [error] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      const alert = findAlert();
      expect(mockHideModal).not.toHaveBeenCalled();
      expect(alert.exists()).toBe(true);
      expect(alert.text()).toContain(error);
    });
  });

  describe('with mocked Apollo client', () => {
    // TODO: Once the BE is complete for the mutation add specs here for that via a destroyHandler
  });
});
