import Vue from 'vue';

import EpicItemTimelineComponent from 'ee/roadmap/components/epic_item_timeline.vue';
import { getTimeframeForQuartersView } from 'ee/roadmap/utils/roadmap_utils';

import { PRESET_TYPES } from 'ee/roadmap/constants';

import mountComponent from 'helpers/vue_mount_component_helper';
import { mockTimeframeInitialDate, mockEpic } from 'ee_jest/roadmap/mock_data';

const mockTimeframeQuarters = getTimeframeForQuartersView(mockTimeframeInitialDate);

const createComponent = ({
  presetType = PRESET_TYPES.QUARTERS,
  timeframe = mockTimeframeQuarters,
  timeframeItem = mockTimeframeQuarters[0],
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

describe('QuartersPresetMixin', () => {
  let vm;

  afterEach(() => {
    vm.$destroy();
  });

  describe('methods', () => {
    describe('hasStartDateForQuarter', () => {
      it('returns true when Epic.startDate falls within timeframeItem', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeQuarters[1].range[0] },
          timeframeItem: mockTimeframeQuarters[1],
        });

        expect(vm.hasStartDateForQuarter()).toBe(true);
      });

      it('returns false when Epic.startDate does not fall within timeframeItem', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeQuarters[0].range[0] },
          timeframeItem: mockTimeframeQuarters[1],
        });

        expect(vm.hasStartDateForQuarter()).toBe(false);
      });
    });

    describe('isTimeframeUnderEndDateForQuarter', () => {
      const timeframeItem = mockTimeframeQuarters[1];

      beforeEach(() => {
        vm = createComponent({});
      });

      it('returns true if provided timeframeItem is under epicEndDate', () => {
        const epicEndDate = mockTimeframeQuarters[1].range[2];

        vm = createComponent({
          epic: { ...mockEpic, endDate: epicEndDate },
        });

        expect(vm.isTimeframeUnderEndDateForQuarter(timeframeItem)).toBe(true);
      });

      it('returns false if provided timeframeItem is NOT under epicEndDate', () => {
        const epicEndDate = mockTimeframeQuarters[2].range[1];

        vm = createComponent({
          epic: { ...mockEpic, endDate: epicEndDate },
        });

        expect(vm.isTimeframeUnderEndDateForQuarter(timeframeItem)).toBe(false);
      });
    });

    describe('getBarWidthForSingleQuarter', () => {
      it('returns calculated bar width based on provided cellWidth, daysInQuarter and day of quarter', () => {
        vm = createComponent({});

        expect(Math.floor(vm.getBarWidthForSingleQuarter(300, 91, 1))).toBe(3); // 10% size
        expect(Math.floor(vm.getBarWidthForSingleQuarter(300, 91, 45))).toBe(148); // 50% size
        expect(vm.getBarWidthForSingleQuarter(300, 91, 91)).toBe(300); // Full size
      });
    });

    describe('getTimelineBarStartOffsetForQuarters', () => {
      it('returns empty string when Epic startDate is out of range', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDateOutOfRange: true },
        });

        expect(vm.getTimelineBarStartOffsetForQuarters(vm.epic)).toBe('');
      });

      it('returns empty string when Epic startDate is undefined and endDate is out of range', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDateUndefined: true, endDateOutOfRange: true },
        });

        expect(vm.getTimelineBarStartOffsetForQuarters(vm.epic)).toBe('');
      });

      it('return `left: 0;` when Epic startDate is first day of the quarter', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeQuarters[0].range[0] },
        });

        expect(vm.getTimelineBarStartOffsetForQuarters(vm.epic)).toBe('left: 0;');
      });

      it('returns proportional `left` value based on Epic startDate and days in the quarter', () => {
        vm = createComponent({
          epic: { ...mockEpic, startDate: mockTimeframeQuarters[0].range[1] },
        });

        expect(vm.getTimelineBarStartOffsetForQuarters(vm.epic)).toContain('left: 34');
      });
    });

    describe('getTimelineBarWidthForQuarters', () => {
      it('returns calculated width value based on Epic.startDate and Epic.endDate', () => {
        vm = createComponent({
          timeframeItem: mockTimeframeQuarters[0],
          epic: {
            ...mockEpic,
            startDate: mockTimeframeQuarters[0].range[1],
            endDate: mockTimeframeQuarters[1].range[1],
          },
        });

        expect(Math.floor(vm.getTimelineBarWidthForQuarters(vm.epic))).toBe(180);
      });
    });
  });
});
