import { shallowMount } from '@vue/test-utils';
import CurrentDayIndicator from 'ee/oncall_schedules/components/schedule/components/current_day_indicator.vue';
import { PRESET_TYPES, DAYS_IN_WEEK, HOURS_IN_DAY } from 'ee/oncall_schedules/constants';
import { useFakeDate } from 'helpers/fake_date';
import { getDayDifference } from '~/lib/utils/datetime_utility';

describe('CurrentDayIndicator', () => {
  let wrapper;
  // January 3rd, 2018 - current date (faked)
  useFakeDate(2018, 0, 3);
  // January 1st, 2018 is the first  day of the week-long timeframe
  // so as long as current date (faked January 3rd, 2018) is within week timeframe
  // current indicator will be rendered
  const mockTimeframeInitialDate = new Date(2018, 0, 1);
  const mockCurrentDate = new Date(2018, 0, 3);
  const weeklyOffset = 100 / DAYS_IN_WEEK / 2;
  const weeklyHourOffset = (weeklyOffset / HOURS_IN_DAY) * mockTimeframeInitialDate.getHours();

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

  it('sets correct styles for a week that on a different day than the timeframe start date', async () => {
    const weeklyDayDifferenceOffset =
      (100 / DAYS_IN_WEEK) * getDayDifference(mockTimeframeInitialDate, mockCurrentDate);
    expect(wrapper.attributes('style')).toBe(
      `left: ${weeklyDayDifferenceOffset + weeklyOffset + weeklyHourOffset}%;`,
    );
  });

  it('sets correct styles for a week that starts on the same day than the timeframe start date', async () => {
    createComponent({
      props: { presetType: PRESET_TYPES.WEEKS, timeframeItem: mockCurrentDate },
    });
    expect(wrapper.attributes('style')).toBe(`left: ${weeklyOffset + weeklyHourOffset}%;`);
  });

  it('sets correct styles for a day', async () => {
    createComponent({
      props: { presetType: PRESET_TYPES.DAYS, timeframeItem: mockCurrentDate },
    });
    const currentDate = new Date();
    const base = 100 / HOURS_IN_DAY;
    const hours = base * currentDate.getHours();
    const minutes = base * (currentDate.getMinutes() / 60) - 2.25;
    const left = hours + minutes;
    expect(wrapper.attributes('style')).toBe(`left: ${left}%;`);
  });
});
