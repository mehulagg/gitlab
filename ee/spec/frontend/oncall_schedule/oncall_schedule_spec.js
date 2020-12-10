import { shallowMount } from '@vue/test-utils';
import { GlCard, GlSprintf, GlButton } from '@gitlab/ui';
import OnCallSchedule, { i18n } from 'ee/oncall_schedules/components/oncall_schedule.vue';
import ScheduleTimelineSection from 'ee/oncall_schedules/components/schedule/components/schedule_timeline_section.vue';
import RotationsListSection from 'ee/oncall_schedules/components/schedule/components/rotations_list_section.vue';
import * as utils from 'ee/oncall_schedules/components/schedule/utils';
import * as commonUtils from 'ee/oncall_schedules/utils/common_utils';
import { PRESET_TYPES } from 'ee/oncall_schedules/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import mockTimezones from './mocks/mockTimezones.json';

describe('On-call schedule', () => {
  let wrapper;
  const lastTz = mockTimezones[mockTimezones.length - 1];
  const mockSchedule = {
    description: 'monitor description',
    iid: '3',
    name: 'monitor schedule',
    timezone: lastTz.identifier,
  };

  const mockWeeksTimeFrame = ['31 Dec 2020', '7 Jan 2021', '14 Jan 2021'];
  const formattedTimezone = '(UTC-09:00) AKST Alaska';

  function mountComponent({ schedule } = {}) {
    wrapper = extendedWrapper(
      shallowMount(OnCallSchedule, {
        propsData: {
          schedule,
        },
        provide: {
          timezones: mockTimezones,
        },
        stubs: {
          GlCard,
          GlSprintf,
        },
      }),
    );
  }

  beforeEach(() => {
    jest.spyOn(utils, 'getTimeframeForWeeksView').mockReturnValue(mockWeeksTimeFrame);
    jest.spyOn(commonUtils, 'getFormattedTimezone').mockReturnValue(formattedTimezone);
    mountComponent({ schedule: mockSchedule });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findOuterCard = () => wrapper.findByTestId('outerCard');
  const findInnerCard = () => wrapper.findByTestId('innerCard');
  const findOuterCardHeader = () => findOuterCard().find('.gl-card-header');
  const findInnerCardHeader = () => findInnerCard().find('.gl-card-header');
  const findOuterCardDescription = () => findOuterCard().find('.gl-card-body');
  const findInnerCardDescription = () => findInnerCard().find('.gl-card-body');
  const findAddRotationsBtn = () => findInnerCardHeader().find(GlButton);
  const findScheduleTimeline = () => findInnerCardDescription().find(ScheduleTimelineSection);
  const findRotationsList = () => findInnerCardDescription().find(RotationsListSection);

  it('shows schedule title', () => {
    expect(findOuterCardHeader().text()).toBe(mockSchedule.name);
  });

  it('shows timezone info', () => {
    const shortTz = i18n.scheduleForTz.replace('%{tzShort}', lastTz.identifier);
    const longTz = formattedTimezone;
    const description = findOuterCardDescription().text();
    expect(description).toContain(shortTz);
    expect(description).toContain(longTz);
  });

  it('renders rotations header', () => {
    expect(findInnerCardHeader().text()).toContain(i18n.rotationTitle);
    expect(findAddRotationsBtn().text()).toContain(i18n.addARotation);
  });

  it('renders schedule timeline', () => {
    const timeline = findScheduleTimeline();
    expect(timeline.exists()).toBe(true);
    expect(timeline.props()).toEqual({
      presetType: PRESET_TYPES.WEEKS,
      timeframe: mockWeeksTimeFrame,
    });
  });

  it('renders rotations list', () => {
    const rotationsList = findRotationsList();
    expect(rotationsList.exists()).toBe(true);
    expect(rotationsList.props()).toEqual({
      presetType: PRESET_TYPES.WEEKS,
      timeframe: mockWeeksTimeFrame,
      rotations: expect.any(Array),
    });
  });
});
