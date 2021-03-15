import { GlAvatar, GlPopover } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import RotationAssignee, {
  SHIFT_WIDTHS,
  TIME_DATE_FORMAT,
} from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { selectedTimezoneFormattedOffset } from 'ee/oncall_schedules/components/schedule/utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { formatDate } from '~/lib/utils/datetime_utility';
import { truncate } from '~/lib/utils/text_utility';
import mockRotations from '../../mocks/mock_rotation.json';
import mockTimezones from '../../mocks/mock_timezones.json';

jest.mock('lodash/uniqueId', () => (prefix) => `${prefix}fakeUniqueId`);

describe('RotationAssignee', () => {
  let wrapper;

  const shiftWidth = SHIFT_WIDTHS.md;
  const assignee = mockRotations[0].shifts.nodes[0];
  const findToken = () => wrapper.findByTestId('rotation-assignee');
  const findAvatar = () => wrapper.findComponent(GlAvatar);
  const findPopOver = () => wrapper.findComponent(GlPopover);
  const findStartsAt = () => wrapper.findByTestId('rotation-assignee-starts-at');
  const findEndsAt = () => wrapper.findByTestId('rotation-assignee-ends-at');
  const findName = () => wrapper.findByTestId('rotation-assignee-name');

  const formattedDate = (date) => {
    return formatDate(date, TIME_DATE_FORMAT);
  };

  const selectedTimezone = mockTimezones[0];

  function createComponent({ props = {} } = {}) {
    wrapper = extendedWrapper(
      shallowMount(RotationAssignee, {
        provide: {
          selectedTimezone,
        },
        propsData: {
          assignee: { ...assignee.participant },
          rotationAssigneeStartsAt: assignee.startsAt,
          rotationAssigneeEndsAt: assignee.endsAt,
          rotationAssigneeStyle: { left: '0px', width: `${shiftWidth}px` },
          shiftWidth,
          ...props,
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

  describe('rotation assignee token', () => {
    it('should render an assignee name and avatar', () => {
      const LARGE_SHIFT_WIDTH = 150;
      createComponent({ props: { shiftWidth: LARGE_SHIFT_WIDTH } });
      expect(findAvatar().props('src')).toBe(assignee.participant.user.avatarUrl);
      expect(findName().text()).toBe(assignee.participant.user.username);
    });

    it('truncate the rotation name on small screens', () => {
      expect(findName().text()).toBe(truncate(assignee.participant.user.username, 3));
    });

    it('hides the rotation name on mobile screens', () => {
      createComponent({ props: { shiftWidth: SHIFT_WIDTHS.sm } });
      expect(findName().exists()).toBe(false);
    });

    it('hides the avatar on the smallest screens', () => {
      createComponent({ props: { shiftWidth: SHIFT_WIDTHS.xs } });
      expect(findAvatar().exists()).toBe(false);
    });

    it('should render an assignee color based on the chevron skipping color pallette', () => {
      const token = findToken();
      expect(token.classes()).toContain(
        `gl-bg-data-viz-${assignee.participant.colorPalette}-${assignee.participant.colorWeight}`,
      );
    });

    it('should render an assignee schedule and rotation information in a popover', () => {
      const timezone = selectedTimezoneFormattedOffset(selectedTimezone.formatted_offset);
      expect(findPopOver().attributes('target')).toBe('rotation-assignee-fakeUniqueId');
      expect(findStartsAt().text()).toContain(`${formattedDate(assignee.startsAt)} ${timezone}`);
      expect(findEndsAt().text()).toContain(`${formattedDate(assignee.endsAt)} ${timezone}`);
    });
  });
});
