import { shallowMount } from '@vue/test-utils';
import CurrentDayIndicator from 'ee/oncall_schedules/components/schedule/components/current_day_indicator.vue';
import { useFakeDate } from 'helpers/fake_date';
import { PRESET_TYPES, DAYS_IN_WEEK, HOURS_IN_DAY } from 'ee/oncall_schedules/constants';

describe('CurrentDayIndicator', () => {
  let wrapper;
  // January 3rd, 2018 - current date (faked)
  useFakeDate(2018, 0, 3);
  // January 1st, 2018 is the first  day of the week-long timeframe
  // so as long as current date (faked January 3rd, 2018) is within week timeframe
  // current indicator will be rendered
  const mockTimeframeInitialDate = new Date(2018, 0, 1);

  function createComponent({
    props = { presetType: PRESET_TYPES.WEEKS, timeframeItem: mockTimeframeInitialDate },
  } = {}) {
    wrapper = shallowMount(CurrentDayIndicator, {
      propsData: {
        ...props,
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

  it('sets correct styles for a week', async () => {
    const left = 100 / DAYS_IN_WEEK / 2;
    expect(wrapper.attributes('style')).toBe(`left: ${left}%;`);
  });

  it('sets correct styles for a day', async () => {
    createComponent({
      props: { presetType: PRESET_TYPES.DAYS, timeframeItem: new Date(2018, 0, 3) },
    });
    const currentDate = new Date();
    const base = 100 / HOURS_IN_DAY;
    const hours = base * currentDate.getHours();
    const minutes = base * (currentDate.getMinutes() / 60) - 2.25;
    const left = hours + minutes;
    expect(wrapper.attributes('style')).toBe(`left: ${left}%;`);
  });
});
