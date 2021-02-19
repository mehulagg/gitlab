import { GlAvatarLabeled, GlAvatarLink, GlAvatar } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Assignee from 'ee/integrations/jira/issues_show/components/sidebar/assignee.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import AssigneeTitle from '~/sidebar/components/assignees/assignee_title.vue';

import { mockJiraIssue } from '../../mock_data';

const mockAssignee = convertObjectPropsToCamelCase(mockJiraIssue.assignees[0], { deep: true });

describe('JiraIssuesSidebarAssignee', () => {
  let wrapper;

  const findNoAssigneeText = () => wrapper.findByTestId('no-assignee-text');
  const findNoAssigneeIcon = () => wrapper.findByTestId('no-assignee-text');
  const findAvatar = () => wrapper.find(GlAvatar);
  const findAvatarLabeled = () => wrapper.find(GlAvatarLabeled);
  const findAvatarLink = () => wrapper.find(GlAvatarLink);
  const findSidebarCollapsedIconWrapper = () =>
    wrapper.findByTestId('sidebar-collapsed-icon-wrapper');

  const createComponent = ({ assignee } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(Assignee, {
        propsData: {
          assignee,
        },
      }),
    );
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('with assignee', () => {
    beforeEach(() => {
      createComponent({ assignee: mockAssignee });
    });

    describe('template', () => {
      it('renders avatar components', () => {
        expect(wrapper.element).toMatchSnapshot();
      });

      it('renders GlAvatarLink with correct props', () => {
        const avatarLink = findAvatarLink();

        expect(avatarLink.exists()).toBe(true);
        expect(avatarLink.attributes()).toMatchObject({
          href: mockAssignee.webUrl,
          title: mockAssignee.name,
        });
      });

      it('renders GlAvatarLabeled with correct props', () => {
        const avatarLabeled = findAvatarLabeled();

        expect(avatarLabeled.exists()).toBe(true);
        expect(avatarLabeled.attributes()).toMatchObject({
          src: mockAssignee.avatarUrl,
          alt: mockAssignee.name,
          'entity-name': mockAssignee.name,
        });
        expect(avatarLabeled.props('label')).toBe(mockAssignee.name);
      });

      it('renders GlAvatar with correct props', () => {
        const avatar = findAvatar();

        expect(avatar.exists()).toBe(true);
        expect(avatar.attributes()).toMatchObject({
          src: mockAssignee.avatarUrl,
          alt: mockAssignee.name,
        });
        expect(avatar.props('entityName')).toBe(mockAssignee.name);
      });

      it('renders AssigneeTitle with correct props', () => {
        const title = wrapper.find(AssigneeTitle);

        expect(title.exists()).toBe(true);
        expect(title.props('numberOfAssignees')).toBe(1);
      });

      it('does not render "No assignee" text', () => {
        expect(findNoAssigneeText().exists()).toBe(false);
      });

      it('does not render "No assignee" icon', () => {
        expect(findNoAssigneeIcon().exists()).toBe(false);
      });

      it('sets `title` attribute of collapsed sidebar wrapper correctly', () => {
        const iconWrapper = findSidebarCollapsedIconWrapper();
        expect(iconWrapper.attributes('title')).toBe(mockAssignee.name);
      });
    });
  });

  describe('with no assignee', () => {
    beforeEach(() => {
      createComponent({ assignee: undefined });
    });

    describe('template', () => {
      it('renders template without avatar components (the "None" state)', () => {
        expect(wrapper.element).toMatchSnapshot();
      });

      it('sets `title` attribute of collapsed sidebar wrapper correctly', () => {
        const iconWrapper = findSidebarCollapsedIconWrapper();
        expect(iconWrapper.attributes('title')).toBe('No assignee');
      });
    });
  });
});
