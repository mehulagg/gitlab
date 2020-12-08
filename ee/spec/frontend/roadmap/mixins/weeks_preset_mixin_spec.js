import EpicItemTimelineComponent from 'ee/roadmap/components/epic_item_timeline.vue';
import { PRESET_TYPES } from 'ee/roadmap/constants';
import { getTimeframeForWeeksView } from 'ee/roadmap/utils/roadmap_utils';

import { mockTimeframeInitialDate, mockEpic } from 'ee_jest/roadmap/mock_data';
import { shallowMount } from '@vue/test-utils';

const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);

describe('WeeksPresetMixin', () => {
  let wrapper;

  const createComponent = ({
    presetType = PRESET_TYPES.WEEKS,
    timeframe = mockTimeframeWeeks,
    timeframeItem = mockTimeframeWeeks[0],
    epic = mockEpic,
  }) => {
    return shallowMount(EpicItemTimelineComponent, {
      propsData: {
        presetType,
        timeframe,
        timeframeItem,
        epic,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('methods', () => {
    describe('hasStartDateForWeek', () => {
      it('returns true when Epic.startDate falls within timeframeItem', () => {
        wrapper = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeWeeks[1] },
          timeframeItem: mockTimeframeWeeks[1],
        });

        expect(wrapper.vm.hasStartDateForWeek()).toBe(true);
      });

      it('returns false when Epic.startDate does not fall within timeframeItem', () => {
        wrapper = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeWeeks[0] },
          timeframeItem: mockTimeframeWeeks[1],
        });

        expect(wrapper.vm.hasStartDateForWeek()).toBe(false);
      });
    });

    describe('getLastDayOfWeek', () => {
      it('returns date object set to last day of the week from provided timeframeItem', () => {
        wrapper = createComponent({});
        const lastDayOfWeek = wrapper.vm.getLastDayOfWeek(mockTimeframeWeeks[0]);

        expect(lastDayOfWeek.getDate()).toBe(23);
        expect(lastDayOfWeek.getMonth()).toBe(11);
        expect(lastDayOfWeek.getFullYear()).toBe(2017);
      });
    });

    describe('isTimeframeUnderEndDateForWeek', () => {
      const timeframeItem = new Date(2018, 0, 7); // Jan 7, 2018

      beforeEach(() => {
        wrapper = createComponent({});
      });

      it('returns true if provided timeframeItem is under epicEndDate', () => {
        const epicEndDate = new Date(2018, 0, 3); // Jan 3, 2018

        wrapper = createComponent({
          epic: { ...mockEpic, endDate: epicEndDate },
        });

        expect(wrapper.vm.isTimeframeUnderEndDateForWeek(timeframeItem)).toBe(true);
      });

      it('returns false if provided timeframeItem is NOT under epicEndDate', () => {
        const epicEndDate = new Date(2018, 0, 15); // Jan 15, 2018

        wrapper = createComponent({
          epic: { ...mockEpic, endDate: epicEndDate },
        });

        expect(wrapper.vm.isTimeframeUnderEndDateForWeek(timeframeItem)).toBe(false);
      });
    });

    describe('getBarWidthForSingleWeek', () => {
      it('returns calculated bar width based on provided cellWidth and day of week', () => {
        wrapper = createComponent({});

        expect(Math.floor(wrapper.vm.getBarWidthForSingleWeek(300, 1))).toBe(42); // 10% size
        expect(Math.floor(wrapper.vm.getBarWidthForSingleWeek(300, 3))).toBe(128); // 50% size
        expect(wrapper.vm.getBarWidthForSingleWeek(300, 7)).toBe(300); // Full size
      });
    });

    describe('getTimelineBarStartOffsetForWeeks', () => {
      it('returns empty string when Epic startDate is out of range', () => {
        wrapper = createComponent({
          epic: { ...mockEpic, startDateOutOfRange: true },
        });

        expect(wrapper.vm.getTimelineBarStartOffsetForWeeks(wrapper.vm.epic)).toBe('');
      });

      it('returns empty string when Epic startDate is undefined and endDate is out of range', () => {
        wrapper = createComponent({
          epic: { ...mockEpic, startDateUndefined: true, endDateOutOfRange: true },
        });

        expect(wrapper.vm.getTimelineBarStartOffsetForWeeks(wrapper.vm.epic)).toBe('');
      });

      it('return `left: 0;` when Epic startDate is first day of the week', () => {
        wrapper = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeWeeks[0] },
        });

        expect(wrapper.vm.getTimelineBarStartOffsetForWeeks(wrapper.vm.epic)).toBe('left: 0;');
      });

      it('returns proportional `left` value based on Epic startDate and days in the week', () => {
        wrapper = createComponent({
          epic: { ...mockEpic, startDate: new Date(2018, 0, 15) },
        });

        expect(wrapper.vm.getTimelineBarStartOffsetForWeeks(wrapper.vm.epic)).toContain('left: 38');
      });
    });

    describe('getTimelineBarWidthForWeeks', () => {
      it('returns calculated width value based on Epic.startDate and Epic.endDate', () => {
        wrapper = createComponent({
          timeframeItem: mockTimeframeWeeks[0],
          epic: {
            ...mockEpic,
            startDate: new Date(2018, 0, 1), // Jan 1, 2018
            endDate: new Date(2018, 1, 2), // Feb 2, 2018
          },
        });

        expect(Math.floor(wrapper.vm.getTimelineBarWidthForWeeks())).toBe(1208);
      });
    });
  });
});
