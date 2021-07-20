import { shallowMount } from '@vue/test-utils';
import DaysHeaderSubItem from 'ee/oncall_schedules/components/schedule/components/preset_days/days_header_sub_item.vue';
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
});
