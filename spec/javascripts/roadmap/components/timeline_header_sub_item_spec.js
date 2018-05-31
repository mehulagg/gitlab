import Vue from 'vue';

import timelineHeaderSubItemComponent from 'ee/roadmap/components/timeline_header_sub_item.vue';

import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { mockTimeframe } from '../mock_data';

const createComponent = ({
  currentDate = mockTimeframe[0],
  timeframeItem = mockTimeframe[0],
}) => {
  const Component = Vue.extend(timelineHeaderSubItemComponent);

  return mountComponent(Component, {
    currentDate,
    timeframeItem,
  });
};

describe('TimelineHeaderSubItemComponent', () => {
  let vm;

  afterEach(() => {
    vm.$destroy();
  });

  describe('computed', () => {
    describe('headerSubItems', () => {
      it('returns array of dates containing Sundays from timeframeItem', () => {
        vm = createComponent({});
        expect(Array.isArray(vm.headerSubItems)).toBe(true);
      });
    });

    describe('headerSubItemClass', () => {
      it('returns string containing `label-dark` when timeframe year and month are greater than current year and month', () => {
        vm = createComponent({});
        expect(vm.headerSubItemClass).toBe('label-dark');
      });

      it('returns empty string when timeframe year and month are less than current year and month', () => {
        vm = createComponent({
          currentDate: new Date(2017, 10, 1), // Nov 1, 2017
          timeframeItem: new Date(2018, 0, 1), // Jan 1, 2018
        });
        expect(vm.headerSubItemClass).toBe('');
      });
    });

    describe('hasToday', () => {
      it('returns true when current month and year is same as timeframe month and year', () => {
        vm = createComponent({});
        expect(vm.hasToday).toBe(true);
      });

      it('returns false when current month and year is different from timeframe month and year', () => {
        vm = createComponent({
          currentDate: new Date(2017, 10, 1), // Nov 1, 2017
          timeframeItem: new Date(2018, 0, 1), // Jan 1, 2018
        });
        expect(vm.hasToday).toBe(false);
      });
    });
  });

  describe('methods', () => {
    describe('getSubItemValueClass', () => {
      it('returns empty string when provided subItem is greater than current date', () => {
        vm = createComponent({
          currentDate: new Date(2018, 0, 1), // Jan 1, 2018
        });
        const subItem = new Date(2018, 0, 15); // Jan 15, 2018
        expect(vm.getSubItemValueClass(subItem)).toBe('');
      });

      it('returns string containing `value-light` when provided subItem is less than current date', () => {
        vm = createComponent({
          currentDate: new Date(2018, 0, 15), // Jan 15, 2018
        });
        const subItem = new Date(2018, 0, 1); // Jan 1, 2018
        expect(vm.getSubItemValueClass(subItem)).toBe('value-light');
      });
    });
  });

  describe('template', () => {
    beforeEach(() => {
      vm = createComponent({});
    });

    it('renders component container element with class `item-sublabel`', () => {
      expect(vm.$el.classList.contains('item-sublabel')).toBe(true);
    });

    it('renders sub item element with class `sublabel-value`', () => {
      expect(vm.$el.querySelector('.sublabel-value')).not.toBeNull();
    });
  });
});
