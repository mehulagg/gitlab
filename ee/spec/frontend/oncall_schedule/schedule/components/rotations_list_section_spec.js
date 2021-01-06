import { mount } from '@vue/test-utils';
import { GlCard } from '@gitlab/ui';
import RotationsListSection from 'ee/oncall_schedules/components/schedule/components/rotations_list_section.vue';
import CurrentDayIndicator from 'ee/oncall_schedules/components/schedule/components/current_day_indicator.vue';
import RotationsAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { getTimeframeForWeeksView } from 'ee/oncall_schedules/components/schedule/utils';
import { PRESET_TYPES } from 'ee/oncall_schedules/constants';
import mockRotations from '../../mocks/mock_rotation.json';

describe('RotationsListSectionComponent', () => {
  let wrapper;
  const mockTimeframeInitialDate = new Date(mockRotations[0].shifts.nodes[0].startsAt);
  const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);
  const projectPath = 'group/project';

  function createComponent({
    presetType = PRESET_TYPES.WEEKS,
    timeframe = mockTimeframeWeeks,
  } = {}) {
    wrapper = mount(RotationsListSection, {
      propsData: {
        presetType,
        timeframe,
        rotations: [mockRotations[0]],
      },
      provide: {
        projectPath,
      },
      stubs: {
        GlCard,
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

  const findTimelineCells = () => wrapper.findAll('[data-testid="timelineCell"]');
  const findRotationAssignees = () => wrapper.findAllComponents(RotationsAssignee);

  it('renders component layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders timeline cell items based on timeframe data', () => {
    expect(findTimelineCells().length).toBe(mockTimeframeWeeks.length);
  });

  it('renders current day indicator in the first timeline cell', () => {
    expect(findTimelineCells().at(0).find(CurrentDayIndicator).exists()).toBe(true);
  });

  it('render the correct amount of rotation assignees with their related information', () => {
    expect(findRotationAssignees()).toHaveLength(2);
    expect(findRotationAssignees().at(0).props().assignee.user).toEqual(
      mockRotations[0].shifts.nodes[0].participant.user,
    );
  });
});
