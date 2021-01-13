import { shallowMount } from '@vue/test-utils';
import ScheduleShift from 'ee/oncall_schedules/components/schedule/components/schedule_shift.vue';
import RotationsAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { PRESET_TYPES } from 'ee/oncall_schedules/constants';

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
const timeframe = [timeframeItem, timeframeItem];

describe('ee/oncall_schedules/components/schedule/components/schedule_shift.vue', () => {
  let wrapper;

  function createComponent({ props = {}, data = {} } = {}) {
    wrapper = shallowMount(ScheduleShift, {
      propsData: {
        shift,
        shiftIndex: 0,
        timeframeItem,
        timeframe,
        presetType: PRESET_TYPES.WEEKS,
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
       * Where left should be 50px i.e. (DAYS_IN_WEEK - (timeframeEndsAt - overlapStartDate)) * CELL_WIDTH((7 - (20 - 14)) * 50)
       * and width should be overlapping days * CELL_WIDTH(1 * 50)
       */
      createComponent({
        props: { shift: { ...shift, startsAt: '2021-01-14T10:04:56.333Z' } },
        data: { shiftTimeUnitWidth: CELL_WIDTH },
      });
      expect(findRotationAssignee().props('rotationAssigneeStyle')).toEqual({
        left: '50px',
        width: '50px',
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
