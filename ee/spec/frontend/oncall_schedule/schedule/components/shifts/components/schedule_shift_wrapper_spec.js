import { shallowMount } from '@vue/test-utils';
import WeeksScheduleShift from 'ee/oncall_schedules/components/schedule/components/shifts/components/weeks_schedule_shift.vue';
import RotationsAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { incrementDateByDays } from 'ee/oncall_schedules/components/schedule/utils';
import { PRESET_TYPES, DAYS_IN_WEEK } from 'ee/oncall_schedules/constants';

const shift = {
  participant: {
    id: '1',
    user: {
      username: 'nora.schaden',
    },
  },
  startsAt: '2021-01-12T10:04:56.333Z',
  endsAt: '2021-01-15T10:04:56.333Z',
};

const timeframeItem = new Date(2021, 0, 13);
const timeframe = [timeframeItem, incrementDateByDays(timeframeItem, DAYS_IN_WEEK)];

describe('ee/oncall_schedules/components/schedule/components/shifts/components/weeks_schedule_shift.vue', () => {
  let wrapper;

  function createComponent({ props = {}, data = {} } = {}) {
    wrapper = shallowMount(WeeksScheduleShift, {
      propsData: {
        shift,
        shiftIndex: 0,
        timeframeItem,
        timeframe,
        presetType: PRESET_TYPES.WEEKS,
        shiftTimeUnitWidth: 0,
        ...props,
      },
      data() {
        return {
          shiftTimeUnitWidth: 0,
          ...data,
        };
      },
      mocks: {
        $apollo: {
          queries: {
            shiftTimeUnitWidth: 0,
          },
        },
      },
    });
  }

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findRotationAssignee = () => wrapper.findComponent(RotationsAssignee);

  describe('shift overlaps inside the current time-frame', () => {});
});
