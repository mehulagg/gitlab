import { shallowMount } from '@vue/test-utils';
import DaysHeaderSubItem from 'ee/oncall_schedules/components/schedule/components/preset_days/days_header_sub_item.vue';
import updateShiftTimeUnitWidthMutation from 'ee/oncall_schedules/graphql/mutations/update_shift_time_unit_width.mutation.graphql';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('ee/oncall_schedules/components/schedule/components/preset_days/days_header_sub_item.vue', () => {
  let wrapper;
  const mockTimeframeItem = new Date(2021, 0, 13);

  function mountComponent({ timeframeItem }) {
    wrapper = extendedWrapper(
      shallowMount(DaysHeaderSubItem, {
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
    mountComponent({ timeframeItem: mockTimeframeItem });
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  const findDaysHeaderSubItem = () => wrapper.findByTestId('day-item-sublabel');
  const findDaysHeaderCurrentIndicator = () =>
    wrapper.findByTestId('day-item-sublabel-current-indicator');

  describe('template', () => {
    it('renders component container element with class `item-sublabel`', () => {
      expect(wrapper.classes()).toContain('item-sublabel');
    });

    it('renders sub item element with class `sublabel-value`', () => {
      expect(wrapper.find('.sublabel-value').exists()).toBe(true);
    });

    it('renders element with class `current-day-indicator-header` when the date is today', () => {
      mountComponent({ timeframeItem: new Date() });
      expect(findDaysHeaderCurrentIndicator().exists()).toBe(true);
    });
  });

  describe('updateShiftStyles', () => {
    it('should store the rendered cell width in Apollo cache via `updateShiftTimeUnitWidthMutation` when mounted', async () => {
      wrapper.vm.$apollo.mutate.mockResolvedValueOnce({});
      await wrapper.vm.$nextTick();
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: updateShiftTimeUnitWidthMutation,
        variables: {
          shiftTimeUnitWidth: wrapper.vm.$refs.dailyHourCell[0].offsetWidth,
        },
      });
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(1);
    });

    it('should re-calculate cell width inside Apollo cache on page resize', () => {
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(1);
      const { value } = getBinding(findDaysHeaderSubItem().element, 'gl-resize-observer');
      value();
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(2);
    });
  });
});
