import { shallowMount } from '@vue/test-utils';
import { GlCard, GlButton } from '@gitlab/ui';
import ScheduleTimelineSection, {
  i18n,
} from 'ee/oncall_schedules/components/schedule/components/schedule_timeline_section.vue';
import WeeksHeaderItem from 'ee/oncall_schedules/components/schedule/components/preset_weeks/weeks_header_item.vue';
import { getTimeframeForWeeksView } from 'ee/oncall_schedules/components/schedule/utils';
import { PRESET_TYPES } from 'ee/oncall_schedules/components/schedule/constants';
import { getOncallSchedulesQueryResponse } from '../../mocks/apollo_mock';

describe('RoadmapTimelineSectionComponent', () => {
  let wrapper;
  const mockTimeframeInitialDate = new Date(2018, 0, 1);
  const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);
  const schedule =
    getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0];

  const findRotations = () => wrapper.find(GlCard);
  const findAddRotation = () => wrapper.find(GlButton);

  function mountComponent({
    presetType = PRESET_TYPES.WEEKS,
    timeframe = mockTimeframeWeeks,
  } = {}) {
    wrapper = shallowMount(ScheduleTimelineSection, {
      propsData: {
        presetType,
        timeframe,
        schedule,
      },
      stubs: {
        GlCard,
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
    expect(wrapper.html()).toContain('timeline-section');
  });

  it('renders empty header cell element with class `timeline-header-blank`', () => {
    expect(wrapper.find('.timeline-header-blank').exists()).toBe(true);
  });

  it('renders weeks header items based on timeframe data', () => {
    expect(wrapper.findAll(WeeksHeaderItem).length).toBe(mockTimeframeWeeks.length);
  });

  it('renders the rotation card wrapper', () => {
    expect(findRotations().exists()).toBe(true);
  });

  it('renders the add rotation button in the rotation card wrapper', () => {
    expect(findAddRotation().exists()).toBe(true);
    expect(findAddRotation().text()).toBe(i18n.addARotation);
  });
});
