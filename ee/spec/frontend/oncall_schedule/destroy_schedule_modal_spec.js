/* eslint-disable no-unused-vars */
import { shallowMount, createLocalVue } from '@vue/test-utils';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import { GlModal } from '@gitlab/ui';
import VueApollo from 'vue-apollo';
import waitForPromises from 'helpers/wait_for_promises';
import destroyOncallScheduleMutation from 'ee/oncall_schedules/graphql/mutations/destroy_oncall_schedule.mutation.graphql';
import DestroyScheduleModal, {
  i18n,
} from 'ee/oncall_schedules/components/destroy_schedule_modal.vue';
import { DELETE_SCHEDULE_ERROR } from 'ee/oncall_schedules/utils/error_messages';
import {
  getOncallSchedulesQueryResponse,
  destroyScheduleResponse,
  scheduleToDestroy,
} from './mocks/apollo_mock';

const localVue = createLocalVue();
const projectPath = 'group/project';
const mutate = jest.fn();
const mockHideModal = jest.fn();

localVue.use(VueApollo);

describe('DestroyScheduleModal', () => {
  let wrapper;
  let fakeApollo;
  let destroyScheduleHandler;

  const findModal = () => wrapper.find(GlModal);

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
    wrapper = shallowMount(DestroyScheduleModal, {
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
    });
    wrapper.vm.$refs.destroyScheduleModal.hide = mockHideModal;
  };

  function createComponentWithApollo({
    destroyHandler = jest.fn().mockResolvedValue(destroyScheduleResponse),
  } = {}) {
    localVue.use(VueApollo);
    destroyScheduleHandler = destroyHandler;

    const requestHandlers = [[destroyOncallScheduleMutation, destroyScheduleHandler]];

    fakeApollo = createMockApollo(requestHandlers);

    wrapper = shallowMount(DestroyScheduleModal, {
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

  it('renders destroy schedule modal layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('renders destroy modal with the correct schedule information', () => {
    it('renders name of correct modal id', () => {
      expect(findModal().attributes('modalid')).toBe('destroyScheduleModal');
    });

    it('renders name of schedule to destroy', () => {
      expect(findModal().html()).toContain(i18n.deleteScheduleMessage);
    });
  });

  describe('Schedule destroy apollo API call', () => {
    it('makes a request with `oncallScheduleDestroy` to destroy a schedule', () => {
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
      mutate.mockResolvedValueOnce({ data: { oncallScheduleDestroy: { errors: [] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      expect(mockHideModal).toHaveBeenCalled();
    });

    it("doesn't hide the modal on fail", async () => {
      const error = 'some error';
      mutate.mockResolvedValueOnce({ data: { oncallScheduleDestroy: { errors: [error] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      expect(mockHideModal).not.toHaveBeenCalled();
    });
  });

  describe('with mocked Apollo client', () => {
    // TODO: Once the BE is complete for the mutation add specs here for that via a destroyHandler
  });
});
