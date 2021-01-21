import { shallowMount } from '@vue/test-utils';
import { GlToken, GlAvatarLabeled, GlPopover } from '@gitlab/ui';
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { formatDate } from '~/lib/utils/datetime_utility';
import mockRotations from '../../mocks/mock_rotation.json';

describe('RotationAssignee', () => {
  let wrapper;

  const assignee = mockRotations[0].shifts.nodes[0];
  const findToken = () => wrapper.findComponent(GlToken);
  const findAvatar = () => wrapper.findComponent(GlAvatarLabeled);
  const findPopOver = () => wrapper.findComponent(GlPopover);
  const findStartsAt = () => wrapper.findByTestId('rotation-assignee-starts-at');
  const findEndsAt = () => wrapper.findByTestId('rotation-assignee-ends-at');

  const formattedDate = (date) => {
    return formatDate(date, 'mmmm d, yyyy, hh:mm');
  };

  function createComponent() {
    wrapper = extendedWrapper(
      shallowMount(RotationAssignee, {
        propsData: {
          assignee: assignee.participant,
          rotationAssigneeStartsAt: assignee.startsAt,
          rotationAssigneeEndsAt: assignee.endsAt,
          rotationAssigneeStyle: { left: '0px', width: '100px' },
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
    it('should render an assignee name', () => {
      expect(findAvatar().attributes('label')).toBe(assignee.participant.user.username);
    });

    it('should render an assignee color based on the chevron skipping color pallette', () => {
      const token = findToken();
      expect(token.classes()).toContain(
        `gl-bg-data-viz-${assignee.participant.colorPalette}-${assignee.participant.colorWeight}`,
      );
    });

    it('should render an assignee schedule and rotation information in a popover', () => {
      expect(findPopOver().attributes('target')).toBe(assignee.participant.id);
      expect(findStartsAt().text()).toContain(formattedDate(assignee.startsAt));
      expect(findEndsAt().text()).toContain(formattedDate(assignee.endsAt));
    });
  });
});
