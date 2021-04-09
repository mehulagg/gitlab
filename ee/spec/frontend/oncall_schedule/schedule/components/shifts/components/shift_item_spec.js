import { shallowMount } from '@vue/test-utils';
import RotationsAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import ShiftItem from 'ee/oncall_schedules/components/schedule/components/shifts/components/shift_item.vue';
import { PRESET_TYPES, DAYS_IN_WEEK } from 'ee/oncall_schedules/constants';
import { nDaysAfter } from '~/lib/utils/datetime_utility';

const shift = {
  participant: {
    id: '1',
    user: {
      username: 'nora.schaden',
    },
  },
  // 3.5 days
  startsAt: '2021-01-12T10:04:56.333Z',
  endsAt: '2021-01-15T22:04:56.333Z',
};

const CELL_WIDTH = 50;
const timeframeItem = new Date(2021, 0, 13);
const timeframe = [timeframeItem, new Date(nDaysAfter(timeframeItem, DAYS_IN_WEEK))];

describe('ee/oncall_schedules/components/schedule/components/shifts/components/shift_item.vue', () => {
  let wrapper;

  function createComponent({ props = {} } = {}) {
    wrapper = shallowMount(ShiftItem, {
      propsData: {
        shift,
        timeframe,
        presetType: PRESET_TYPES.WEEKS,
        timelineWidth: CELL_WIDTH * 14,
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

  describe('shift overlaps inside the current time-frame with a shift greater than 24 hours', () => {
    it('should render a rotation assignee child component', () => {
      expect(findRotationAssignee().exists()).toBe(true);
    });
  });

  describe('shift overlaps inside the current time-frame with a shift equal to 24 hours', () => {
    beforeEach(() => {
      createComponent({
        props: { shift: { ...shift, startsAt: '2021-01-14T10:04:56.333Z' } },
        data: { shiftTimeUnitWidth: CELL_WIDTH },
      });
    });

    it('should render a rotation assignee child component', () => {
      expect(findRotationAssignee().exists()).toBe(true);
    });
  });

  describe('shift overlaps inside the current time-frame with a shift less than 24 hours', () => {
    beforeEach(() => {
      createComponent({
        props: {
          shift: {
            ...shift,
            startsAt: '2021-01-14T10:04:56.333Z',
            endsAt: '2021-01-14T12:04:56.333Z',
          },
          rotationLength: { lengthUnit: 'HOURS' },
        },
        data: { shiftTimeUnitWidth: CELL_WIDTH },
      });
    });

    it('should render a rotation assignee child component', () => {
      expect(findRotationAssignee().exists()).toBe(true);
    });
  });
});
