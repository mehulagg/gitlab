import VueApollo from 'vue-apollo';
import { mount, createLocalVue } from '@vue/test-utils';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import { GlEmptyState } from '@gitlab/ui';
import OnCallScheduleWrapper, {
  i18n,
} from 'ee/oncall_schedules/components/oncall_schedules_wrapper.vue';
import OncallSchedule from 'ee/oncall_schedules/components/oncall_schedule.vue';
import getOncallSchedulesQuery from 'ee/oncall_schedules/graphql/get_oncall_schedules.query.graphql';
import destroyOncallScheduleMutation from 'ee/oncall_schedules/graphql/mutations/destroy_oncall_schedule.mutation.graphql';
import { DELETE_SCHEDULE_ERROR } from 'ee/oncall_schedules/utils/error_messages';
import createFlash from '~/flash';
import {
  projectPath,
  getOncallSchedulesQueryResponse,
  destroyScheduleResponse,
  scheduleToDestroy,
  destroyScheduleResponseWithErrors,
} from './mocks/apollo_mock';
import mockTimezones from './mocks/mockTimezones.json';

jest.mock('~/flash');

const localVue = createLocalVue();

describe('OnCallScheduleWrapper', () => {
  let wrapper;
  let fakeApollo;
  let destroyScheduleHandler;
  const emptyOncallSchedulesSvgPath = 'illustration/path.svg';

  const findSchedules = () => wrapper.find(OncallSchedule).findAll('.gl-card');
  const findEmptyState = () => wrapper.find(GlEmptyState);

  async function destroySchedule(localWrapper) {
    await jest.runOnlyPendingTimers();
    await localWrapper.vm.$nextTick();

    localWrapper.find(OncallSchedule).vm.$emit('delete-schedule', { id: scheduleToDestroy.id });
  }

  async function awaitApolloDomMock() {
    await wrapper.vm.$nextTick(); // kick off the DOM update
    await jest.runOnlyPendingTimers(); // kick off the mocked GQL stuff (promises)
    await wrapper.vm.$nextTick(); // kick off the DOM update for flash
  }

  function mountComponent({ data = {}, provide = {}, loading = false } = {}) {
    wrapper = mount(OnCallScheduleWrapper, {
      data() {
        return { ...data };
      },
      provide: {
        emptyOncallSchedulesSvgPath,
        projectPath,
        timezones: mockTimezones,
        ...provide,
      },
      mocks: {
        $apollo: {
          mutate: jest.fn(),
          query: jest.fn(),
          queries: {
            schedule: {
              loading,
            },
          },
        },
      },
    });
  }

  function createComponentWithApollo({
    destroyHandler = jest.fn().mockResolvedValue(destroyScheduleResponse),
  } = {}) {
    localVue.use(VueApollo);
    destroyScheduleHandler = destroyHandler;

    const requestHandlers = [
      [getOncallSchedulesQuery, jest.fn().mockResolvedValue(getOncallSchedulesQueryResponse)],
      [destroyOncallScheduleMutation, destroyScheduleHandler],
    ];

    fakeApollo = createMockApollo(requestHandlers);

    wrapper = mount(OnCallScheduleWrapper, {
      localVue,
      apolloProvider: fakeApollo,
      provide: {
        emptyOncallSchedulesSvgPath,
        projectPath,
        timezones: mockTimezones,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('Empty state', () => {
    it('shows empty state and passed correct attributes to it', () => {
      mountComponent({
        data: { schedule: null },
      });

      expect(findEmptyState().exists()).toBe(true);
      expect(findEmptyState().props('title')).toBe(i18n.emptyState.title);
      expect(findEmptyState().props('description')).toBe(i18n.emptyState.description);
      expect(
        findEmptyState()
          .find('img')
          .attributes('src'),
      ).toBe(emptyOncallSchedulesSvgPath);
    });
  });

  describe('with mocked Apollo client', () => {
    it('has a selection of schedules loaded via the getOncallSchedulesQuery', async () => {
      createComponentWithApollo();

      await jest.runOnlyPendingTimers();
      await wrapper.vm.$nextTick();

      expect(findSchedules()).toHaveLength(1);
    });

    it('calls a mutation with correct parameters and destroys a schedule', async () => {
      createComponentWithApollo();

      await destroySchedule(wrapper);

      expect(destroyScheduleHandler).toHaveBeenCalled();

      await wrapper.vm.$nextTick();

      expect(findSchedules()).toHaveLength(0);
    });

    it('displays flash if mutation had a recoverable error', async () => {
      createComponentWithApollo({
        destroyHandler: jest.fn().mockResolvedValue(destroyScheduleResponseWithErrors),
      });

      await destroySchedule(wrapper);
      await awaitApolloDomMock();

      expect(createFlash).toHaveBeenCalledWith({ message: 'Houston, we have a problem' });
    });

    it('displays flash if mutation had a non-recoverable error', async () => {
      createComponentWithApollo({
        destroyHandler: jest.fn().mockRejectedValue('Error'),
      });

      await destroySchedule(wrapper);
      await awaitApolloDomMock();

      expect(createFlash).toHaveBeenCalledWith({
        message: DELETE_SCHEDULE_ERROR,
      });
    });
  });
});
