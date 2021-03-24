import { shallowMount } from '@vue/test-utils';
import RotationsAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import DaysScheduleShift from 'ee/oncall_schedules/components/schedule/components/shifts/components/days_schedule_shift.vue';
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
        timelineWidth: CELL_WIDTH,
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
      createComponent({ data: { timelineWidth: CELL_WIDTH } });
      expect(findRotationAssignee().props('rotationAssigneeStyle')).toEqual({
        left: '0px',
        width: '248px',
      });
    });

    it('calculates the correct rotation assignee styles when the shift does not start at the beginning of the time-frame cell', () => {
      /**
       * Where left should be 500px i.e. ((HOURS_IN_DAY - (HOURS_IN_DAY - overlapStartTime)) * CELL_WIDTH) (((24 - (24 - 10)) * 50))
       * and width should be overlapping hours * CELL_WIDTH (12 * 50 - 2)
       */
      createComponent({
        props: {
          shift: {
            ...shift,
            startsAt: '2021-01-15T10:04:56.333Z',
            endsAt: '2021-01-15T22:04:56.333Z',
          },
        },
        data: { timelineWidth: CELL_WIDTH },
      });
      expect(findRotationAssignee().props('rotationAssigneeStyle')).toEqual({
        left: '500px',
        width: '598px',
      });
    });

    it('handles the offset for timezone changes', () => {
      const DLSTimeframeItem = new Date(2021, 2, 14);
      const DSLTimeframe = [timeframeItem, nDaysAfter(timeframeItem, DAYS_IN_WEEK)];
      /**
       * Where left should be: ((HOURS_IN_DAY - (HOURS_IN_DAY - overlapStartTime)) * CELL_WIDTH)
       * and width should be: (overlappingHours + timezoneOffset) * CELL_WIDTH
       */
      createComponent({
        props: {
          shift: {
            ...shift,
            startsAt: '2021-03-14T05:00:00Z',
            endsAt: '2021-03-14T07:00:00Z',
          },
          timeframeItem: DLSTimeframeItem,
          timeframe: DSLTimeframe,
        },
        data: { timelineWidth: CELL_WIDTH },
      });
      expect(findRotationAssignee().props('rotationAssigneeStyle')).toEqual({
        left: '250px',
        width: '98px',
      });
    });
  });
});
