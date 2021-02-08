import { shallowMount } from '@vue/test-utils';
import DaysScheduleShift from 'ee/oncall_schedules/components/schedule/components/shifts/components/days_schedule_shift.vue';
import RotationsAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { PRESET_TYPES, DAYS_IN_WEEK } from 'ee/oncall_schedules/constants';
import { nDaysAfter } from '~/lib/utils/datetime_utility';

const shift = {
  participant: {
    id: '1',
    user: {
      username: 'nora.schaden',
    },
  },
  startsAt: '2021-01-15T00:04:56.333Z',
  endsAt: '2021-01-15T04:22:56.333Z',
};

const CELL_WIDTH = 50;
const timeframeItem = new Date(2021, 0, 15);
const timeframe = [timeframeItem, nDaysAfter(timeframeItem, DAYS_IN_WEEK)];

describe('ee/oncall_schedules/components/schedule/components/shifts/components/days_schedule_shift.vue', () => {
  let wrapper;

  function createComponent({ props = {} } = {}) {
    wrapper = shallowMount(DaysScheduleShift, {
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
       * and width should be overlapping hours * CELL_WIDTH(5 * 50)
       */
      createComponent({ data: { shiftTimeUnitWidth: CELL_WIDTH } });
      expect(findRotationAssignee().props('rotationAssigneeStyle')).toEqual({
        left: '0px',
        width: '250px',
      });
    });

    it('calculates the correct rotation assignee styles when the shift does not start at the beginning of the time-frame cell', () => {
      /**
       * Where left should be 502px i.e. ((HOURS_IN_DAY - (HOURS_IN_DAY - overlapStartTime)) * CELL_WIDTH) + ASSIGNEE_SPACER(((24 - (24 - 9)) * 50)) + 2
       * and width should be overlapping hours * CELL_WIDTH(12 * 50 + 50)
       */
      createComponent({
        props: {
          shift: {
            ...shift,
            startsAt: '2021-01-15T10:04:56.333Z',
            endsAt: '2021-01-15T22:04:56.333Z',
          },
        },
        data: { shiftTimeUnitWidth: CELL_WIDTH },
      });
      expect(findRotationAssignee().props('rotationAssigneeStyle')).toEqual({
        left: '452px',
        width: '650px',
      });
    });
  });

  describe('shift does not overlap inside the current time-frame or contains an invalid date', () => {
    it.each`
      reason                                            | setTimeframeItem         | startsAt                      | endsAt
      ${'timeframe is an invalid date'}                 | ${new Date(NaN)}         | ${shift.startsAt}             | ${shift.endsAt}
      ${'shift start date is an invalid date'}          | ${timeframeItem}         | ${'Invalid date string'}      | ${shift.endsAt}
      ${'shift end date is an invalid date'}            | ${timeframeItem}         | ${shift.startsAt}             | ${'Invalid date string'}
      ${'shift is not inside the timeframe'}            | ${timeframeItem}         | ${'2021-03-12T10:00:00.000Z'} | ${'2021-03-16T10:00:00.000Z'}
      ${'timeframe does not represent the shift times'} | ${new Date(2021, 3, 21)} | ${shift.startsAt}             | ${shift.endsAt}
    `(`should not render a rotation item when $reason`, (data) => {
      const { setTimeframeItem, startsAt, endsAt } = data;
      createComponent({
        props: {
          timeframeItem: setTimeframeItem,
          shift: { ...shift, startsAt, endsAt },
        },
      });

      expect(findRotationAssignee().exists()).toBe(false);
    });
  });
});
