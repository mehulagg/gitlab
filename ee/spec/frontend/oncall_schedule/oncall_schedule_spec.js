import { shallowMount } from '@vue/test-utils';
import { GlCard, GlSprintf } from '@gitlab/ui';
import OnCallSchedule, { i18n } from 'ee/oncall_schedules/components/oncall_schedule.vue';
import ScheduleTimelineSection from 'ee/oncall_schedules/components/schedule/components/schedule_timeline_section.vue';
import * as utils from 'ee/oncall_schedules/components/schedule/utils';
import * as commonUtils from 'ee/oncall_schedules/utils';
import { PRESET_TYPES } from 'ee/oncall_schedules/components/schedule/constants';
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
    wrapper = shallowMount(OnCallSchedule, {
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
    });
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

  const findCardHeader = () => wrapper.find('.gl-card-header');
  const findCardDescription = () => wrapper.find('.gl-card-body');
  const findScheduleTimeline = () => findCardDescription().find(ScheduleTimelineSection);

  it('shows schedule title', () => {
    expect(findCardHeader().text()).toBe(mockSchedule.name);
  });

  it('shows timezone info', () => {
    const shortTz = i18n.scheduleForTz.replace('%{tzShort}', lastTz.identifier);
    const longTz = formattedTimezone;
    const description = findCardDescription().text();
    expect(description).toContain(shortTz);
    expect(description).toContain(longTz);
  });

  it('renders ScheduleShell', () => {
    const timeline = findScheduleTimeline();
    expect(timeline.exists()).toBe(true);
    expect(timeline.props()).toEqual({
      presetType: PRESET_TYPES.WEEKS,
      timeframe: mockWeeksTimeFrame,
    });
  });
});
