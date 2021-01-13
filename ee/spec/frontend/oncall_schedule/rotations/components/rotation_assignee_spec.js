import { shallowMount } from '@vue/test-utils';
import { GlToken, GlAvatarLabeled, GlPopover } from '@gitlab/ui';
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import mockRotations from '../../mocks/mock_rotation.json';

describe('RotationAssignee', () => {
  let wrapper;

  const assignee = mockRotations[0].participants.nodes[1];
  const findToken = () => wrapper.find(GlToken);
  const findAvatar = () => wrapper.find(GlAvatarLabeled);
  const findPopOver = () => wrapper.find(GlPopover);
  const findStartsAt = () => wrapper.findByTestId('rotation-assignee-starts-at');
  const findEndsAt = () => wrapper.findByTestId('rotation-assignee-ends-at');

  function createComponent() {
    wrapper = extendedWrapper(
      shallowMount(RotationAssignee, {
        propsData: {
          assignee,
          assigneeIndex: 1,
          rotationLength: mockRotations[0].length,
          rotationStartsAt: mockRotations[0].startsAt,
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
      expect(findAvatar().attributes('label')).toBe(assignee.user.username);
    });

    it('should render an assignee avatar', () => {
      expect(findAvatar().attributes('src')).toBe(assignee.user.avatarUrl);
    });

    it('should render an assignee color based on the chevron skipping color pallette', () => {
      const token = findToken();
      expect(token.classes()).toContain(
        `gl-bg-data-viz-${assignee.colorPalette}-${assignee.colorWeight}`,
      );
    });

    it('should render an assignee schedule and rotation information in a popover', () => {
      expect(findPopOver().attributes('target')).toBe(assignee.user.id);
      // starts at the beginning of the rotation time
      expect(findStartsAt().text()).toContain('12/16/2020');
      // ends at the calculated length of the rotation for this user: rotation length * which user index assignee is at
      expect(findEndsAt().text()).toContain('12/23/2020');
    });
  });
});
