import { shallowMount } from '@vue/test-utils';
import DaysHeaderItem from 'ee/oncall_schedules/components/schedule/components/preset_days/days_header_item.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { useFakeDate } from 'helpers/fake_date';

describe('ee/oncall_schedules/components/schedule/components/preset_days/days_header_item.vue', () => {
  let wrapper;
  // January 3rd, 2018 - current date (faked)
  useFakeDate(2018, 0, 3);
  const mockTimeframeInitialDate = new Date(2018, 0, 1);

  function mountComponent({ timeframeItem = mockTimeframeInitialDate } = {}) {
    wrapper = extendedWrapper(
      shallowMount(DaysHeaderItem, {
        propsData: {
          timeframeItem,
        },
      }),
    );
  }

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  const findHeaderLabel = () => wrapper.findByTestId('timeline-header-label');

  describe('timelineHeaderLabel', () => {
    it('returns string containing Year, Month and Date for the current timeframe item', () => {
      expect(findHeaderLabel().text()).toBe('January 1, 2018');
    });
  });
});
