import { shallowMount } from '@vue/test-utils';
import { GlCard } from '@gitlab/ui';
import RotationsListSection from 'ee/oncall_schedules/components/schedule/components/rotations_list_section.vue';
import CurrentDayIndicator from 'ee/oncall_schedules/components/schedule/components/current_day_indicator.vue';
import { getTimeframeForWeeksView } from 'ee/oncall_schedules/components/schedule/utils';
import { PRESET_TYPES } from 'ee/oncall_schedules/constants';
import mockRotations from '../../mocks/mock_rotation.json';

describe('RotationsListSectionComponent', () => {
  let wrapper;
  const mockTimeframeInitialDate = new Date(2018, 0, 1);
  const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);

  function mountComponent({
    presetType = PRESET_TYPES.WEEKS,
    timeframe = mockTimeframeWeeks,
  } = {}) {
    wrapper = shallowMount(RotationsListSection, {
      propsData: {
        presetType,
        timeframe,
        rotations: [mockRotations[0]],
      },
      stubs: {
        GlCard,
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

  const findTimelineCells = () => wrapper.findAll('[data-testid="timelineCell"]');

  it('renders component layout', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders timeline cell items based on timeframe data', () => {
    expect(findTimelineCells().length).toBe(mockTimeframeWeeks.length);
  });

  it('renders current day indicator in the first timeline cell', () => {
    expect(
      findTimelineCells()
        .at(0)
        .find(CurrentDayIndicator)
        .exists(),
    ).toBe(true);
  });
});
