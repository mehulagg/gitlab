import { shallowMount } from '@vue/test-utils';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import WeeksHeaderSubItemComponent from 'ee/oncall_schedules/components/schedule/components/preset_weeks/weeks_header_sub_item.vue';
import { getTimeframeForWeeksView } from 'ee/oncall_schedules/components/schedule/utils';
import updateShiftTimeUnitWidthMutation from 'ee/oncall_schedules/graphql/mutations/update_shift_time_unit_width.mutation.graphql';
import { useFakeDate } from 'helpers/fake_date';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('WeeksHeaderSubItemComponent', () => {
  let wrapper;
  // January 3rd, 2018 - current date (faked)
  useFakeDate(2018, 0, 3);
  const mockTimeframeInitialDate = new Date(2018, 0, 1);
  const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);

  function mountComponent({ timeframeItem = mockTimeframeWeeks[0] }) {
    wrapper = extendedWrapper(
      shallowMount(WeeksHeaderSubItemComponent, {
        propsData: {
          timeframeItem,
        },
        directives: {
          GlResizeObserver: createMockDirective(),
        },
        mocks: {
          $apollo: {
            mutate: jest.fn(),
          },
        },
      }),
    );
  }

  beforeEach(() => {
    mountComponent({});
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  const findSublabelValues = () => wrapper.findAll('[data-testid="sublabel-value"]');
  const findWeeksHeaderSubItemComponent = () => wrapper.findByTestId('week-item-sublabel');

  describe('computed', () => {
    describe('headerSubItems', () => {
      it('returns `headerSubItems` array of dates containing days of week from timeframeItem', () => {
        expect(wrapper.vm.headerSubItems).toBeInstanceOf(Array);
        expect(wrapper.vm.headerSubItems).toHaveLength(7);
        wrapper.vm.headerSubItems.forEach((subItem) => {
          expect(subItem).toBeInstanceOf(Date);
        });
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
      // January 1st, 2018 is the first  day of the week-long timeframe
      // so as long as current date (faked January 3rd, 2018) is within week timeframe
      // current indicator will be rendered
      expect(wrapper.find('.current-day-indicator-header.preset-weeks').exists()).toBe(true);
    });

    it('sublabel has `label-dark` class when it is for the day greater than current week day', () => {
      // Timeframe starts at Jan 1, 2018, faked today is Jan 3, 2018 (3rd item in a week timeframe)
      // labels for dates after current have 'label-dark' class
      expect(findSublabelValues().at(3).classes()).toContain('label-dark');
    });

    it("sublabel has `label-dark label-bold` classes when it is for today's date", () => {
      // Timeframe starts at Jan 1, 2018, faked today is Jan 3, 2018 (3rd item in a week timeframe)
      expect(findSublabelValues().at(2).classes()).toEqual(
        expect.arrayContaining(['label-dark', 'label-bold']),
      );
    });

    it('should store the rendered cell width in Apollo cache via `updateShiftTimeUnitWidthMutation` when mounted', async () => {
      wrapper.vm.$apollo.mutate.mockResolvedValueOnce({});
      await wrapper.vm.$nextTick();
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: updateShiftTimeUnitWidthMutation,
        variables: {
          shiftTimeUnitWidth: wrapper.vm.$refs.weeklyDayCell[0].offsetWidth,
        },
      });
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(1);
    });

    it('should re-calculate cell width inside Apollo cache on page resize', () => {
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(1);
      const { value } = getBinding(findWeeksHeaderSubItemComponent().element, 'gl-resize-observer');
      value();
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(2);
    });
  });
});
