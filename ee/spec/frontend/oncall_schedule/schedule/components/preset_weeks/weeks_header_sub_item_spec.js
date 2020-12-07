import { shallowMount } from '@vue/test-utils';
import WeeksHeaderSubItemComponent from 'ee/oncall_schedules/components/schedule/components/preset_weeks/weeks_header_sub_item.vue';
import { getTimeframeForWeeksView } from 'ee/oncall_schedules/components/schedule/utils';
import { PRESET_TYPES } from 'ee/oncall_schedules/components/schedule/constants';

describe('MonthsHeaderSubItemComponent', () => {
  let wrapper;
  const mockTimeframeInitialDate = new Date(2018, 0, 1);
  const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);

  function mountComponent({
    currentDate = mockTimeframeWeeks[0],
    timeframeItem = mockTimeframeWeeks[0],
  }) {
    wrapper = shallowMount(WeeksHeaderSubItemComponent, {
      propsData: {
        currentDate,
        timeframeItem,
      },
    });
  }

  beforeEach(() => {
    mountComponent({});
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  describe('data', () => {
    it('initializes `presetType` and `indicatorStyles` data props', () => {
      expect(wrapper.vm.presetType).toBe(PRESET_TYPES.WEEKS);
      expect(wrapper.vm.indicatorStyle).toBeDefined();
    });
  });

  describe('computed', () => {
    describe('headerSubItems', () => {
      it('returns `headerSubItems` array of dates containing days of week from timeframeItem', () => {
        expect(wrapper.vm.headerSubItems).toBeInstanceOf(Array);
        expect(wrapper.vm.headerSubItems).toHaveLength(7);
        wrapper.vm.headerSubItems.forEach(subItem => {
          expect(subItem).toBeInstanceOf(Date);
        });
      });
    });
  });

  describe('methods', () => {
    describe('getSubItemValueClass', () => {
      it('returns string containing `label-dark` when provided subItem is greater than current week day', () => {
        mountComponent({
          currentDate: new Date(2018, 0, 1), // Jan 1, 2018
        });
        const subItem = new Date(2018, 0, 25); // Jan 25, 2018

        expect(wrapper.vm.getSubItemValueClass(subItem)).toBe('label-dark');
      });

      it('returns string containing `label-dark label-bold` when provided subItem is same as current week day', () => {
        const currentDate = new Date(2018, 0, 25);
        mountComponent({
          currentDate,
        });
        const subItem = currentDate;

        expect(wrapper.vm.getSubItemValueClass(subItem)).toBe('label-dark label-bold');
      });
    });
  });

  describe('template', () => {
    it('renders component container element with class `item-sublabel`', () => {
      expect(wrapper.classes()).toContain('item-sublabel');
    });

    it('renders sub item element with class `sublabel-value`', () => {
      expect(wrapper.find('.sublabel-value').exists()).toBe(true);
    });

    it('renders element with class `current-day-indicator-header` when hasToday is true', () => {
      expect(wrapper.find('.current-day-indicator-header.preset-weeks').exists()).toBe(true);
    });
  });
});
