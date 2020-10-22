import Vue from 'vue';

import EpicItemTimelineComponent from 'ee/roadmap/components/epic_item_timeline.vue';
import { getTimeframeForMonthsView } from 'ee/roadmap/utils/roadmap_utils';

import { PRESET_TYPES } from 'ee/roadmap/constants';

import mountComponent from 'helpers/vue_mount_component_helper';
import { mockTimeframeInitialDate, mockEpic } from 'ee_jest/roadmap/mock_data';

const mockTimeframeMonths = getTimeframeForMonthsView(mockTimeframeInitialDate);

const createComponent = ({
  presetType = PRESET_TYPES.MONTHS,
  timeframe = mockTimeframeMonths,
  timeframeItem = mockTimeframeMonths[0],
  epic = mockEpic,
}) => {
  const Component = Vue.extend(EpicItemTimelineComponent);

  return mountComponent(Component, {
    presetType,
    timeframe,
    timeframeItem,
    epic,
  });
};

describe('MonthsPresetMixin', () => {
  let vm;

  afterEach(() => {
    vm.$destroy();
  });

  describe('methods', () => {
    describe('hasStartDateForMonth', () => {
      it('returns true when Epic.startDate falls within timeframeItem', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeMonths[1] },
          timeframeItem: mockTimeframeMonths[1],
        });

        expect(vm.hasStartDateForMonth()).toBe(true);
      });

      it('returns false when Epic.startDate does not fall within timeframeItem', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeMonths[0] },
          timeframeItem: mockTimeframeMonths[1],
        });

        expect(vm.hasStartDateForMonth()).toBe(false);
      });
    });

    describe('isTimeframeUnderEndDateForMonth', () => {
      const timeframeItem = new Date(2018, 0, 10); // Jan 10, 2018

      beforeEach(() => {
        vm = createComponent({});
      });

      it('returns true if provided timeframeItem is under epicEndDate', () => {
        const epicEndDate = new Date(2018, 0, 26); // Jan 26, 2018

        vm = createComponent({
          epic: { ...mockEpic, endDate: epicEndDate },
        });

        expect(vm.isTimeframeUnderEndDateForMonth(timeframeItem)).toBe(true);
      });

      it('returns false if provided timeframeItem is NOT under epicEndDate', () => {
        const epicEndDate = new Date(2018, 1, 26); // Feb 26, 2018

        vm = createComponent({
          epic: { ...mockEpic, endDate: epicEndDate },
        });

        expect(vm.isTimeframeUnderEndDateForMonth(timeframeItem)).toBe(false);
      });
    });

    describe('getBarWidthForSingleMonth', () => {
      it('returns calculated bar width based on provided cellWidth, daysInMonth and date', () => {
        vm = createComponent({});

        expect(vm.getBarWidthForSingleMonth(300, 30, 1)).toBe(10); // 10% size
        expect(vm.getBarWidthForSingleMonth(300, 30, 15)).toBe(150); // 50% size
        expect(vm.getBarWidthForSingleMonth(300, 30, 30)).toBe(300); // Full size
      });
    });

    describe('getTimelineBarStartOffsetForMonths', () => {
      it('returns empty string when Epic startDate is out of range', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDateOutOfRange: true },
        });

        expect(vm.getTimelineBarStartOffsetForMonths(vm.epic)).toBe('');
      });

      it('returns empty string when Epic startDate is undefined and endDate is out of range', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDateUndefined: true, endDateOutOfRange: true },
        });

        expect(vm.getTimelineBarStartOffsetForMonths(vm.epic)).toBe('');
      });

      it('return `left: 0;` when Epic startDate is first day of the month', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: new Date(2018, 0, 1) },
        });

        expect(vm.getTimelineBarStartOffsetForMonths(vm.epic)).toBe('left: 0;');
      });

      it('returns proportional `left` value based on Epic startDate and days in the month', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: new Date(2018, 0, 15) },
        });

        expect(vm.getTimelineBarStartOffsetForMonths(vm.epic)).toContain('left: 50%');
      });
    });

    describe('getTimelineBarWidthForMonths', () => {
      it('returns calculated width value based on Epic.startDate and Epic.endDate', () => {
        vm = createComponent({
          timeframeItem: mockTimeframeMonths[0],
          epic: {
            ...mockEpic,
            startDate: new Date(2017, 11, 15), // Dec 15, 2017
            endDate: new Date(2018, 1, 15), // Feb 15, 2017
          },
        });

        expect(Math.floor(vm.getTimelineBarWidthForMonths())).toBe(546);
      });
    });
  });
});
