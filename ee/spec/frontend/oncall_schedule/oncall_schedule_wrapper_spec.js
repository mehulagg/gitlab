import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlEmptyState, GlLoadingIcon, GlAlert } from '@gitlab/ui';
import OnCallScheduleWrapper, {
  i18n,
} from 'ee/oncall_schedules/components/oncall_schedules_wrapper.vue';
import OnCallSchedule from 'ee/oncall_schedules/components/oncall_schedule.vue';
import AddScheduleModal from 'ee/oncall_schedules/components/add_edit_schedule_modal.vue';
import createMockApollo from 'helpers/mock_apollo_helper';
import getOncallSchedulesQuery from 'ee/oncall_schedules/graphql/queries/get_oncall_schedules.query.graphql';
import VueApollo from 'vue-apollo';
import { preExistingSchedule, newlyCreatedSchedule } from './mocks/apollo_mock';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('On-call schedule wrapper', () => {
  let wrapper;
  const emptyOncallSchedulesSvgPath = 'illustration/path.svg';
  const projectPath = 'group/project';

  function mountComponent({ loading, schedule } = {}) {
    const $apollo = {
      queries: {
        schedule: {
          loading,
        },
      },
    };

    wrapper = shallowMount(OnCallScheduleWrapper, {
      data() {
        return {
          schedule,
        };
      },
      provide: {
        emptyOncallSchedulesSvgPath,
        projectPath,
      },
      mocks: { $apollo },
    });
  }

  let getOncallSchedulesQuerySpy;

  function mountComponentWithApollo() {
    const fakeApollo = createMockApollo([[getOncallSchedulesQuery, getOncallSchedulesQuerySpy]]);

    wrapper = shallowMount(OnCallScheduleWrapper, {
      localVue,
      apolloProvider: fakeApollo,
      data() {
        return {
          schedule: {},
        };
      },
      provide: {
        emptyOncallSchedulesSvgPath,
        projectPath,
      },
    });
  }

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findLoader = () => wrapper.find(GlLoadingIcon);
  const findEmptyState = () => wrapper.find(GlEmptyState);
  const findSchedule = () => wrapper.find(OnCallSchedule);
  const findAlert = () => wrapper.find(GlAlert);
  const findModal = () => wrapper.find(AddScheduleModal);

  it('shows a loader while data is requested', () => {
    mountComponent({ loading: true });
    expect(findLoader().exists()).toBe(true);
  });

  it('shows empty state and passed correct attributes to it when not loading and no schedule', () => {
    mountComponent({ loading: false, schedule: null });
    const emptyState = findEmptyState();

    expect(emptyState.exists()).toBe(true);
    expect(emptyState.attributes()).toEqual({
      title: i18n.emptyState.title,
      svgpath: emptyOncallSchedulesSvgPath,
      description: i18n.emptyState.description,
    });
  });

  describe('Schedule created', () => {
    beforeEach(() => {
      mountComponent({ loading: false, schedule: { name: 'monitor rotation' } });
    });

    it('renders the schedule when data received ', () => {
      expect(findLoader().exists()).toBe(false);
      expect(findEmptyState().exists()).toBe(false);
      expect(findSchedule().exists()).toBe(true);
    });

    it('shows success alert', async () => {
      await findModal().vm.$emit('scheduleCreated');
      const alert = findAlert();
      expect(alert.exists()).toBe(true);
      expect(alert.props('title')).toBe(i18n.successNotification.title);
      expect(alert.text()).toBe(i18n.successNotification.description);
    });

    it('renders a newly created schedule', async () => {
      await findModal().vm.$emit('scheduleCreated');
      expect(findSchedule().exists()).toBe(true);
    });
  });

  describe('Apollo', () => {
    beforeEach(() => {
      getOncallSchedulesQuerySpy = jest.fn().mockResolvedValue({
        data: {
          project: {
            incidentManagementOncallSchedules: {
              nodes: [preExistingSchedule, newlyCreatedSchedule],
            },
          },
        },
      });
    });

    it('should render newly create schedule', async () => {
      mountComponentWithApollo();
      jest.runOnlyPendingTimers();
      await wrapper.vm.$nextTick();
      expect(findSchedule().props('schedule')).toEqual(newlyCreatedSchedule);
    });
  });
});
