import { shallowMount } from '@vue/test-utils';
import { GlEmptyState, GlLoadingIcon } from '@gitlab/ui';
import OnCallScheduleWrapper, {
  i18n,
} from 'ee/oncall_schedules/components/oncall_schedules_wrapper.vue';
import OnCallSchedule from 'ee/oncall_schedules/components/oncall_schedule.vue';

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

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findLoader = () => wrapper.find(GlLoadingIcon);
  const findEmptyState = () => wrapper.find(GlEmptyState);
  const findSchedule = () => wrapper.find(OnCallSchedule);

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

  it('renders On-call schedule when data received ', () => {
    mountComponent({ loading: false, schedule: { name: 'monitor rotation' } });
    const schedule = findSchedule();
    expect(findLoader().exists()).toBe(false);
    expect(findEmptyState().exists()).toBe(false);
    expect(schedule.exists()).toBe(true);
  });
});
