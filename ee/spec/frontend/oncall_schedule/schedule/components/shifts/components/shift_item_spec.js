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
  startsAt: '2021-01-15T04:00:00.000Z',
  endsAt: '2021-01-15T06:00:00.000Z', // absolute shift length is 2 hours(7200000 milliseconds)
};

const CELL_WIDTH = 50;
const timeframeItem = new Date(2021, 0, 13); // Timeframe starts on the 13th
const timeframe = [timeframeItem, new Date(nDaysAfter(timeframeItem, DAYS_IN_WEEK))];

describe('ee/oncall_schedules/components/schedule/components/shifts/components/shift_item.vue', () => {
  let wrapper;

  function createComponent({ props = {} } = {}) {
    wrapper = shallowMount(ShiftItem, {
      propsData: {
        shift,
        timeframe,
        presetType: PRESET_TYPES.WEEKS, // Total grid time in MS: 1209600000
        timelineWidth: CELL_WIDTH * 14, // Total grid width in px: 700
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

  it('should render a rotation assignee child component', () => {
    expect(findRotationAssignee().exists()).toBe(true);
  });

  it('should calculate a rotation assignee child components width based on its absolute time', () => {
    // See `getPixelWidth`
    // const width = ((durationMillis + DLSOffset) * timelineWidth) / totalTime;
    // ((7200000 + 0) * 700) / 1209600000
    expect(findRotationAssignee().props('rotationAssigneeStyle').width).toBe('4px');
  });

  it('should calculate a shift width the same as rotation assignee child components width', () => {
    expect(findRotationAssignee().props('shiftWidth')).toBe(4);
  });

  it('should a rotation assignee child components offset based on its absolute time', () => {
    // See `getPixelOffset`
    // const left = (timelineWidth * timeOffset) / totalTime;
    // (700 * 187200000) / 1209600000
    const rotationAssigneeOffset = parseFloat(
      findRotationAssignee().props('rotationAssigneeStyle').left,
    );
    expect(rotationAssigneeOffset).toBeCloseTo(108.33);
  });
});
