import { shallowMount } from '@vue/test-utils';
import CurrentDayIndicator from 'ee/oncall_schedules/components/schedule/components/current_day_indicator.vue';
import { getTimeframeForWeeksView } from 'ee/oncall_schedules/components/schedule/utils';
import { PRESET_TYPES, DAYS_IN_WEEK } from 'ee/oncall_schedules/constants';

describe('CurrentDayIndicator', () => {
  let wrapper;

  const mockTimeframeInitialDate = new Date(2018, 0, 1);
  const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);
  const mockTimeframeItem = getTimeframeForWeeksView(mockTimeframeInitialDate)[0];

  function mountComponent() {
    wrapper = shallowMount(CurrentDayIndicator, {
      propsData: {
        presetType: PRESET_TYPES.WEEKS,
        timeframeItem: mockTimeframeItem,
      },
    });
  }

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  describe('data', () => {
    it('initializes currentDate and indicatorStyles props with default values', () => {
      const currentDate = new Date();
      expect(wrapper.vm.currentDate.getDate()).toBe(currentDate.getDate());
      expect(wrapper.vm.currentDate.getMonth()).toBe(currentDate.getMonth());
      expect(wrapper.vm.currentDate.getFullYear()).toBe(currentDate.getFullYear());
      expect(wrapper.vm.indicatorStyles).toBeDefined();
    });
  });

  describe('computed', () => {
    describe('hasToday', () => {
      it('returns true when presetType is WEEKS and currentDate is within current week', () => {
        wrapper.setData({
          currentDate: mockTimeframeWeeks[0],
        });

        wrapper.setProps({
          presetType: PRESET_TYPES.WEEKS,
          timeframeItem: mockTimeframeWeeks[0],
        });

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.hasToday).toBe(true);
        });
      });
    });
  });

  describe('methods', () => {
    describe('getIndicatorStyles', () => {
      it('returns object containing `left` offset', () => {
        const left = 100 / DAYS_IN_WEEK / 2;
        expect(wrapper.vm.getIndicatorStyles()).toEqual(
          expect.objectContaining({
            left: `${left}%`,
          }),
        );
      });
    });
  });

  describe('template', () => {
    it('renders span element containing class `current-day-indicator`', async () => {
      await wrapper.setData({
        currentDate: mockTimeframeWeeks[0],
      });
      expect(wrapper.classes('current-day-indicator')).toBe(true);
    });
  });
});
