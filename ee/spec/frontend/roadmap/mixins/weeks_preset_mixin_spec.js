import Vue from 'vue';

import EpicItemTimelineComponent from 'ee/roadmap/components/epic_item_timeline.vue';
import { getTimeframeForWeeksView } from 'ee/roadmap/utils/roadmap_utils';

import { PRESET_TYPES } from 'ee/roadmap/constants';

import mountComponent from 'helpers/vue_mount_component_helper';
import { mockTimeframeInitialDate, mockEpic } from 'ee_jest/roadmap/mock_data';

const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);

const createComponent = ({
  presetType = PRESET_TYPES.WEEKS,
  timeframe = mockTimeframeWeeks,
  timeframeItem = mockTimeframeWeeks[0],
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

describe('WeeksPresetMixin', () => {
  let vm;

  afterEach(() => {
    vm.$destroy();
  });

  describe('methods', () => {
    describe('hasStartDateForWeek', () => {
      it('returns true when Epic.startDate falls within timeframeItem', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeWeeks[1] },
          timeframeItem: mockTimeframeWeeks[1],
        });

        expect(vm.hasStartDateForWeek()).toBe(true);
      });

      it('returns false when Epic.startDate does not fall within timeframeItem', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeWeeks[0] },
          timeframeItem: mockTimeframeWeeks[1],
        });

        expect(vm.hasStartDateForWeek()).toBe(false);
      });
    });

    describe('getLastDayOfWeek', () => {
      it('returns date object set to last day of the week from provided timeframeItem', () => {
        vm = createComponent({});
        const lastDayOfWeek = vm.getLastDayOfWeek(mockTimeframeWeeks[0]);

        expect(lastDayOfWeek.getDate()).toBe(23);
        expect(lastDayOfWeek.getMonth()).toBe(11);
        expect(lastDayOfWeek.getFullYear()).toBe(2017);
      });
    });

    describe('isTimeframeUnderEndDateForWeek', () => {
      const timeframeItem = new Date(2018, 0, 7); // Jan 7, 2018

      beforeEach(() => {
        vm = createComponent({});
      });

      it('returns true if provided timeframeItem is under epicEndDate', () => {
        const epicEndDate = new Date(2018, 0, 3); // Jan 3, 2018

        vm = createComponent({
          epic: { ...mockEpic, endDate: epicEndDate },
        });

        expect(vm.isTimeframeUnderEndDateForWeek(timeframeItem)).toBe(true);
      });

      it('returns false if provided timeframeItem is NOT under epicEndDate', () => {
        const epicEndDate = new Date(2018, 0, 15); // Jan 15, 2018

        vm = createComponent({
          epic: { ...mockEpic, endDate: epicEndDate },
        });

        expect(vm.isTimeframeUnderEndDateForWeek(timeframeItem)).toBe(false);
      });
    });

    describe('getBarWidthForSingleWeek', () => {
      it('returns calculated bar width based on provided cellWidth and day of week', () => {
        vm = createComponent({});

        expect(Math.floor(vm.getBarWidthForSingleWeek(300, 1))).toBe(42); // 10% size
        expect(Math.floor(vm.getBarWidthForSingleWeek(300, 3))).toBe(128); // 50% size
        expect(vm.getBarWidthForSingleWeek(300, 7)).toBe(300); // Full size
      });
    });

    describe('getTimelineBarStartOffsetForWeeks', () => {
      it('returns empty string when Epic startDate is out of range', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDateOutOfRange: true },
        });

        expect(vm.getTimelineBarStartOffsetForWeeks(vm.epic)).toBe('');
      });

      it('returns empty string when Epic startDate is undefined and endDate is out of range', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDateUndefined: true, endDateOutOfRange: true },
        });

        expect(vm.getTimelineBarStartOffsetForWeeks(vm.epic)).toBe('');
      });

      it('return `left: 0;` when Epic startDate is first day of the week', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeWeeks[0] },
        });

        expect(vm.getTimelineBarStartOffsetForWeeks(vm.epic)).toBe('left: 0;');
      });

      it('returns proportional `left` value based on Epic startDate and days in the week', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: new Date(2018, 0, 15) },
        });

        expect(vm.getTimelineBarStartOffsetForWeeks(vm.epic)).toContain('left: 38');
      });
    });

    describe('getTimelineBarWidthForWeeks', () => {
      it('returns calculated width value based on Epic.startDate and Epic.endDate', () => {
        vm = createComponent({
          timeframeItem: mockTimeframeWeeks[0],
          epic: {
            ...mockEpic,
            startDate: new Date(2018, 0, 1), // Jan 1, 2018
            endDate: new Date(2018, 1, 2), // Feb 2, 2018
          },
        });

        expect(Math.floor(vm.getTimelineBarWidthForWeeks())).toBe(1208);
      });
    });
  });
});
