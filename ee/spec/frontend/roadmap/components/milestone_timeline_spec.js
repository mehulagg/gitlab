import { shallowMount } from '@vue/test-utils';

import MilestoneTimelineComponent from 'ee/roadmap/components/milestone_timeline.vue';
import MilestoneItem from 'ee/roadmap/components/milestone_item.vue';
import { getTimeframeForMonthsView } from 'ee/roadmap/utils/roadmap_utils';

import { PRESET_TYPES } from 'ee/roadmap/constants';

import { mockTimeframeInitialDate, mockMilestone2, mockGroupId } from 'ee_jest/roadmap/mock_data';

const mockTimeframeMonths = getTimeframeForMonthsView(mockTimeframeInitialDate);

describe('MilestoneTimelineComponent', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
  });

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(MilestoneTimelineComponent, {
      propsData: {
        presetType: PRESET_TYPES.MONTHS,
        timeframe: mockTimeframeMonths,
        milestones: [mockMilestone2],
        currentGroupId: mockGroupId,
        milestonesExpanded: true,
        ...props,
      },
    });
  };

  const findMilestoneItem = () => wrapper.find(MilestoneItem);

  describe.each`
    props                            | hasMilestoneItem
    ${{}}                            | ${true}
    ${{ milestonesExpanded: false }} | ${false}
  `('with $props', ({ props, hasMilestoneItem }) => {
    beforeEach(() => {
      createWrapper(props);
    });

    it(`renders MilestoneItem component = ${hasMilestoneItem}`, () => {
      expect(findMilestoneItem().exists()).toBe(hasMilestoneItem);
    });
  });
});
