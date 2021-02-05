import { shallowMount } from '@vue/test-utils';
import ScheduleShiftWrapper from 'ee/oncall_schedules/components/schedule/components/shifts/components/schedule_shift_wrapper.vue';
import DaysScheduleShift from 'ee/oncall_schedules/components/schedule/components/shifts/components/days_schedule_shift.vue';
import WeeksScheduleShift from 'ee/oncall_schedules/components/schedule/components/shifts/components/weeks_schedule_shift.vue';
import { PRESET_TYPES, DAYS_IN_WEEK } from 'ee/oncall_schedules/constants';
import { nDaysAfter } from '~/lib/utils/datetime_utility';
import mockRotations from '../../../../mocks/mock_rotation.json';

const timeframeItem = new Date(2021, 0, 13);
const timeframe = [timeframeItem, nDaysAfter(timeframeItem, DAYS_IN_WEEK)];

describe('ee/oncall_schedules/components/schedule/components/shifts/components/schedule_shift_wrapper.vue', () => {
  let wrapper;

  function createComponent({ props = { presetType: PRESET_TYPES.WEEKS }, data = {} } = {}) {
    wrapper = shallowMount(ScheduleShiftWrapper, {
      propsData: {
        timeframeItem,
        timeframe,
        rotation: mockRotations[0],
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

  const findDaysScheduleShifts = () => wrapper.findAllComponents(DaysScheduleShift);
  const findWeeksScheduleShifts = () => wrapper.findAllComponents(WeeksScheduleShift);

  describe('when the preset type is WEEKS', () => {
    it('should render a selection of week grid shifts inside the rotation', () => {
      expect(findWeeksScheduleShifts()).toHaveLength(2);
    });
  });

  describe('when the preset type is DAYS', () => {
    it('should render a selection of day grid shifts inside the rotation', () => {
      createComponent({ props: { presetType: PRESET_TYPES.DAYS } });
      expect(findDaysScheduleShifts()).toHaveLength(2);
    });
  });
});
