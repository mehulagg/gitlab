import { shallowMount } from '@vue/test-utils';
import DaysHeaderItem from 'ee/oncall_schedules/components/schedule/components/preset_days/days_header_item.vue';
import WeeksHeaderItem from 'ee/oncall_schedules/components/schedule/components/preset_weeks/weeks_header_item.vue';
import ScheduleTimelineSection from 'ee/oncall_schedules/components/schedule/components/schedule_timeline_section.vue';
import { getTimeframeForWeeksView } from 'ee/oncall_schedules/components/schedule/utils';
import { PRESET_TYPES } from 'ee/oncall_schedules/constants';
import updateTimelineWidthMutation from 'ee/oncall_schedules/graphql/mutations/update_timeline_width.mutation.graphql';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { getOncallSchedulesQueryResponse } from '../../mocks/apollo_mock';

describe('TimelineSectionComponent', () => {
  let wrapper;
  const mockTimeframeInitialDate = new Date(2018, 0, 1);
  const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);
  const schedule =
    getOncallSchedulesQueryResponse.data.project.incidentManagementOncallSchedules.nodes[0];

  function createComponent({
    props = { presetType: PRESET_TYPES.WEEKS, timeframe: mockTimeframeWeeks },
  } = {}) {
    wrapper = extendedWrapper(
      shallowMount(ScheduleTimelineSection, {
        propsData: {
          schedule,
          ...props,
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
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findTimelineWrapper = () => wrapper.findByTestId('timeline-header-wrapper');

  it('renders component container element with class `timeline-section`', () => {
    expect(wrapper.html()).toContain('timeline-section');
  });

  it('renders empty header cell element with class `timeline-header-blank`', () => {
    expect(wrapper.find('.timeline-header-blank').exists()).toBe(true);
  });

  it('renders weeks header items based on timeframe data', () => {
    expect(wrapper.findAllComponents(WeeksHeaderItem)).toHaveLength(mockTimeframeWeeks.length);
  });

  it('renders days header items based on timeframe data', () => {
    createComponent({ props: { presetType: PRESET_TYPES.DAYS, timeframe: mockTimeframeWeeks } });
    expect(wrapper.findAllComponents(DaysHeaderItem)).toHaveLength(1);
  });

  describe('updateShiftStyles', () => {
    it('should store the rendered cell width in Apollo cache via `updateTimelineWidthMutation` when mounted', async () => {
      wrapper.vm.$apollo.mutate.mockResolvedValueOnce({});
      await wrapper.vm.$nextTick();
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: updateTimelineWidthMutation,
        variables: {
          timelineWidth: wrapper.vm.$refs.timelineHeaderWrapper.offsetWidth,
        },
      });
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(1);
    });

    it('should re-calculate cell width inside Apollo cache on page resize', () => {
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(1);
      const { value } = getBinding(findTimelineWrapper().element, 'gl-resize-observer');
      value();
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(2);
    });
  });
});
