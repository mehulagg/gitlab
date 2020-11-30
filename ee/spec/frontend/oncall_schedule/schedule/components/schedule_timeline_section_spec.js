import { shallowMount } from '@vue/test-utils';
import ScheduleTimelineSection from 'ee/oncall_schedules/components/schedule/components/schedule_timeline_section.vue';
import WeeksHeaderItem from 'ee/oncall_schedules/components/schedule/components/preset_weeks/weeks_header_item.vue';
import { getTimeframeForWeeksView } from 'ee/oncall_schedules/components/schedule/utils';
import { PRESET_TYPES } from 'ee/oncall_schedules/components/schedule/constants';

describe('RoadmapTimelineSectionComponent', () => {
  let wrapper;
  const mockTimeframeInitialDate = new Date(2018, 0, 1);
  const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);

  function mountComponent({
    presetType = PRESET_TYPES.WEEKS,
    timeframe = mockTimeframeWeeks,
  } = {}) {
    wrapper = shallowMount(ScheduleTimelineSection, {
      propsData: {
        presetType,
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

  it('renders component container element with class `timeline-section`', () => {
    expect(wrapper.classes()).toContain('timeline-section');
  });

  it('renders empty header cell element with class `timeline-header-blank`', () => {
    expect(wrapper.find('.timeline-header-blank').exists()).toBe(true);
  });

  it('renders weeks header items based on timeframe data', () => {
    expect(wrapper.findAll(WeeksHeaderItem).length).toBe(mockTimeframeWeeks.length);
  });
});
