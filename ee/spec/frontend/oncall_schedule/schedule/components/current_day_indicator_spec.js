import { shallowMount } from '@vue/test-utils';
import CurrentDayIndicator from 'ee/oncall_schedules/components/schedule/components/current_day_indicator.vue';
import { useFakeDate } from 'helpers/fake_date';
import { PRESET_TYPES, DAYS_IN_WEEK } from 'ee/oncall_schedules/constants';

describe('CurrentDayIndicator', () => {
  let wrapper;
  // January 3rd, 2018 - current date (faked)
  useFakeDate(2018, 0, 3);
  // January 1st, 2018 is the first  day of the week-long timeframe
  // so as long as current date (faked January 3rd, 2018) is within week timeframe
  // current indicator will be rendered
  const mockTimeframeInitialDate = new Date(2018, 0, 1);

  function createComponent() {
    wrapper = shallowMount(CurrentDayIndicator, {
      propsData: {
        presetType: PRESET_TYPES.WEEKS,
        timeframeItem: mockTimeframeInitialDate,
      },
    });
  }

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  it('renders span element containing class `current-day-indicator`', () => {
    expect(wrapper.classes('current-day-indicator')).toBe(true);
  });

  it('sets correct styles', async () => {
    const left = 100 / DAYS_IN_WEEK / 2;
    expect(wrapper.attributes('style')).toBe(`left: ${left}%;`);
  });
});
