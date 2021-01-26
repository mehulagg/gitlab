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

const CELL_WIDTH = 50;
const timeframeItem = new Date(2021, 0, 13);
const timeframe = [timeframeItem, incrementDateByDays(timeframeItem, DAYS_IN_WEEK)];

describe('ee/oncall_schedules/components/schedule/components/shifts/components/weeks_schedule_shift.vue', () => {
  let wrapper;

  function createComponent({ props = {} } = {}) {
    wrapper = shallowMount(WeeksScheduleShift, {
      propsData: {
        shift,
        shiftIndex: 0,
        timeframeItem,
        timeframe,
        presetType: PRESET_TYPES.WEEKS,
        shiftTimeUnitWidth: CELL_WIDTH,
        ...props,
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

  describe('shift overlaps inside the current time-frame', () => {
    it('should render a rotation assignee child component', () => {
      expect(findRotationAssignee().exists()).toBe(true);
    });

    it('calculates the correct rotation assignee styles when the shift starts at the beginning of the time-frame cell', () => {
      /**
       * Where left should be 0px i.e. beginning of time-frame cell
       * and width should be overlapping days * CELL_WIDTH(3 * 50)
       */
      createComponent({ data: { shiftTimeUnitWidth: CELL_WIDTH } });
      expect(findRotationAssignee().props('rotationAssigneeStyle')).toEqual({
        left: '0px',
        width: '150px',
      });
    });

    it('calculates the correct rotation assignee styles when the shift does not start at the beginning of the time-frame cell', () => {
      /**
       * Where left should be 52px i.e. ((DAYS_IN_WEEK - (timeframeEndsAt - overlapStartDate)) * CELL_WIDTH) + ASSIGNEE_SPACER(((7 - (20 - 14)) * 50)) + 2
       * and width should be overlapping days * (CELL_WIDTH + offset)(1 * (50 + 50))
       * where offset is either CELL_WIDTH * 0 or CELL_WIDTH * 1 depending on the index of the timeframe
       */
      createComponent({
        props: { shift: { ...shift, startsAt: '2021-01-14T10:04:56.333Z' } },
        data: { shiftTimeUnitWidth: CELL_WIDTH },
      });
      expect(findRotationAssignee().props('rotationAssigneeStyle')).toEqual({
        left: '52px',
        width: '100px',
      });
    });
  });

  describe('shift does not overlap inside the current time-frame or contains an invalid date', () => {
    it.each`
      reason                                            | expectedTimeframeItem    | startsAt                      | endsAt
      ${'timeframe is an invalid date'}                 | ${new Date(NaN)}         | ${shift.startsAt}             | ${shift.endsAt}
      ${'shift start date is an invalid date'}          | ${timeframeItem}         | ${'Invalid date string'}      | ${shift.endsAt}
      ${'shift end date is an invalid date'}            | ${timeframeItem}         | ${shift.startsAt}             | ${'Invalid date string'}
      ${'shift is not inside the timeframe'}            | ${timeframeItem}         | ${'2021-03-12T10:00:00.000Z'} | ${'2021-03-16T10:00:00.000Z'}
      ${'timeframe does not represent the shift times'} | ${new Date(2021, 3, 21)} | ${shift.startsAt}             | ${shift.endsAt}
    `(`should not render a rotation item when $reason`, (data) => {
      const { expectedTimeframeItem, startsAt, endsAt } = data;
      createComponent({
        props: {
          timeframeItem: expectedTimeframeItem,
          shift: { ...shift, startsAt, endsAt },
        },
      });

      expect(findRotationAssignee().exists()).toBe(false);
    });
  });
});
