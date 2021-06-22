import { shallowMount } from '@vue/test-utils';
import {
  PRESET_TYPES,
  oneHourOffsetDayView,
  oneDayOffsetWeekView,
  oneHourOffsetWeekView,
} from 'ee/oncall_schedules/constants';
import CommonMixin from 'ee/oncall_schedules/mixins/common_mixin';
import { useFakeDate } from 'helpers/fake_date';
import * as dateTimeUtility from '~/lib/utils/datetime/date_calculation_utility';

describe('Schedule Common Mixins', () => {
  // January 3rd, 2018
  useFakeDate(2018, 0, 3);

  let today;
  let wrapper;

  beforeEach(() => {
    today = new Date();
  });

  const component = {
    template: `<span></span>`,
    props: {
      timeframeItem: {
        type: [Date, Object],
        required: true,
      },
    },
    mixins: [CommonMixin],
  };

  const mountComponent = (props = {}) => {
    wrapper = shallowMount(component, {
      propsData: {
        timeframeItem: today,
        ...props,
      },
    });
  };

  describe('data', () => {
    it('initializes currentDate default value', () => {
      mountComponent();

      expect(wrapper.vm.$options.currentDate).toEqual(today);
    });
  });

  describe('isToday', () => {
    it('returns true when date is today', () => {
      const result = true;
      jest.spyOn(dateTimeUtility, 'isToday').mockReturnValue(result);
      mountComponent();

      expect(wrapper.vm.isToday).toBe(result);
    });
    it('returns false when date is NOT today', () => {
      const result = false;
      jest.spyOn(dateTimeUtility, 'isToday').mockReturnValue(result);
      mountComponent();

      expect(wrapper.vm.isToday).toBe(result);
    });
  });

  describe('hasToday', () => {
    it('returns true when today (January 3rd, 2018) is within the set week (January 1st, 2018)', () => {
      // January 1st, 2018
      mountComponent({
        timeframeItem: new Date(2018, 0, 1),
      });

      expect(wrapper.vm.hasToday).toBe(true);
    });

    it('returns false when today (January 3rd, 2018) is NOT within the set week (January 8th, 2018)', () => {
      // February 1st, 2018
      mountComponent({
        timeframeItem: new Date(2018, 0, 8),
      });

      expect(wrapper.vm.hasToday).toBe(false);
    });
  });

  describe('getIndicatorStyles', () => {
    it('returns object containing `left` offset for the weekly grid', () => {
      const mockTimeframeInitialDate = new Date(2018, 0, 1);
      const mockCurrentDate = new Date(2018, 0, 3);
      const hourOffset = oneHourOffsetWeekView * mockCurrentDate.getHours();
      const daysSinceShiftStart = dateTimeUtility.getDayDifference(
        mockTimeframeInitialDate,
        mockCurrentDate,
      );
      const leftOffset = oneDayOffsetWeekView * daysSinceShiftStart + hourOffset;
      expect(wrapper.vm.getIndicatorStyles(PRESET_TYPES.WEEKS, mockTimeframeInitialDate)).toEqual(
        expect.objectContaining({
          left: `${leftOffset}%`,
        }),
      );
    });

    it('returns object containing `left` offset for a single day grid', () => {
      const currentDate = new Date(2018, 0, 8);
      const hours = oneHourOffsetDayView * currentDate.getHours();
      const minutes = oneHourOffsetDayView * (currentDate.getMinutes() / 60);

      expect(wrapper.vm.getIndicatorStyles(PRESET_TYPES.DAYS)).toEqual(
        expect.objectContaining({
          left: `${hours + minutes}%`,
        }),
      );
    });
  });
});
