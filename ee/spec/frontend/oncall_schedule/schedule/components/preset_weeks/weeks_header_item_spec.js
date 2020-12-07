import { shallowMount } from '@vue/test-utils';
import WeeksHeaderItemComponent from 'ee/oncall_schedules/components/schedule/components/preset_weeks/weeks_header_item.vue';
import { getTimeframeForWeeksView } from 'ee/oncall_schedules/components/schedule/utils';

describe('WeeksHeaderItemComponent', () => {
  let wrapper;
  const mockTimeframeIndex = 0;
  const mockTimeframeInitialDate = new Date(2018, 0, 1);
  const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);

  function mountComponent({
    timeframeIndex = mockTimeframeIndex,
    timeframeItem = mockTimeframeWeeks[mockTimeframeIndex],
    timeframe = mockTimeframeWeeks,
  }) {
    wrapper = shallowMount(WeeksHeaderItemComponent, {
      propsData: {
        timeframeIndex,
        timeframeItem,
        timeframe,
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
    it('returns default data props', () => {
      const currentDate = new Date();
      expect(wrapper.vm.currentDate.getDate()).toBe(currentDate.getDate());
    });
  });

  describe('computed', () => {
    describe('lastDayOfCurrentWeek', () => {
      it('returns date object representing last day of the week as set in `timeframeItem`', () => {
        expect(wrapper.vm.lastDayOfCurrentWeek.getDate()).toBe(
          mockTimeframeWeeks[mockTimeframeIndex].getDate() + 7,
        );
      });
    });

    describe('timelineHeaderLabel', () => {
      it('returns string containing Year, Month and Date for the first timeframe item in the entire timeframe', () => {
        expect(wrapper.vm.timelineHeaderLabel).toBe('2018 Jan 1');
      });

      it('returns string containing Year, Month and Date for timeframe item when it is first week of the year', () => {
        mountComponent({
          timeframeIndex: 3,
          timeframeItem: new Date(2019, 0, 6),
        });

        expect(wrapper.vm.timelineHeaderLabel).toBe('2019 Jan 6');
      });

      it('returns string containing only Month and Date timeframe item when it is somewhere in the middle of timeframe', () => {
        mountComponent({
          timeframeIndex: mockTimeframeIndex + 1,
          timeframeItem: mockTimeframeWeeks[mockTimeframeIndex + 1],
        });

        expect(wrapper.vm.timelineHeaderLabel).toBe('Jan 8');
      });
    });

    describe('timelineHeaderClass', () => {
      it('returns empty string when timeframeItem week is less than current week', () => {
        expect(wrapper.vm.timelineHeaderClass).toBe('');
      });

      it('returns string containing `label-dark label-bold` when current week is same as timeframeItem week', () => {
        wrapper.setData({ currentDate: mockTimeframeWeeks[mockTimeframeIndex] });

        expect(wrapper.vm.timelineHeaderClass).toBe('label-dark label-bold');
      });
    });
  });

  describe('template', () => {
    it('renders component container element with class `timeline-header-item`', () => {
      expect(wrapper.classes()).toContain('timeline-header-item');
    });

    it('renders item label element class `item-label` and value as `timelineHeaderLabel`', () => {
      expect(wrapper.find('.item-label').text()).toBe('2018 Jan 1');
    });
  });
});
