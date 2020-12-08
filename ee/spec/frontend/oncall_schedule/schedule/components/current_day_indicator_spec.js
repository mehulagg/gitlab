import { shallowMount } from '@vue/test-utils';
import CurrentDayIndicator from 'ee/oncall_schedules/components/schedule/components/current_day_indicator.vue';
import { getTimeframeForWeeksView } from 'ee/oncall_schedules/components/schedule/utils';
import { PRESET_TYPES, DAYS_IN_WEEK } from 'ee/oncall_schedules/components/schedule/constants';

describe('CurrentDayIndicator', () => {
  let wrapper;

  const mockTimeframeInitialDate = new Date(2018, 0, 1);
  const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);
  const mockTimeframeItem = mockTimeframeWeeks[0];

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

  it('renders span element containing class `current-day-indicator`', async () => {
    await wrapper.setData({
      currentDate: mockTimeframeItem,
    });
    expect(wrapper.classes('current-day-indicator')).toBe(true);
  });

  it('sets correct styles', async () => {
    const left = 100 / DAYS_IN_WEEK / 2;
    await wrapper.setData({
      currentDate: mockTimeframeItem,
    });
    expect(wrapper.attributes('style')).toEqual(`left: ${left}%;`);
  });
});
