import { GlAvatarLink, GlAvatarLabeled } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import BoardSettingsListTypes from 'ee_component/boards/components/board_settings_list_types.vue';

describe('BoardSettingsListType', () => {
  let wrapper;
  const activeList = {
    milestone: {
      webUrl: 'https://gitlab.com/h5bp/html5-boilerplate/-/milestones/1',
      title: 'Backlog',
    },
    assignee: { webUrl: 'https://gitlab.com/root', name: 'root', username: 'root' },
  };
  const createComponent = props => {
    wrapper = shallowMount(BoardSettingsListTypes, {
      propsData: { ...props, activeList },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when list type is "milestone"', () => {
    it('renders the correct milestone text', () => {
      createComponent({ activeId: 1, boardListType: 'milestone' });

      expect(wrapper.find('.js-milestone').text()).toBe('Backlog');
    });

    it('renders the correct list type text', () => {
      createComponent({ activeId: 1, boardListType: 'milestone' });

      expect(wrapper.find('.js-list-label').text()).toBe('Milestone');
    });
  });

  describe('when list type is "assignee"', () => {
    afterEach(() => {
      wrapper.destroy();
    });

    it('renders gl-avatar-link with correct href', () => {
      createComponent({ activeId: 1, boardListType: 'assignee' });

      expect(wrapper.find(GlAvatarLink).exists()).toBe(true);
      expect(wrapper.find(GlAvatarLink).attributes('href')).toBe('https://gitlab.com/root');
    });

    it('renders gl-avatar-labeled with "root" as username and name as "root"', () => {
      createComponent({ activeId: 1, boardListType: 'assignee' });

      expect(wrapper.find(GlAvatarLabeled).exists()).toBe(true);
      expect(wrapper.find(GlAvatarLabeled).attributes('label')).toBe('root');
      expect(wrapper.find(GlAvatarLabeled).attributes('sublabel')).toBe('@root');
    });

    it('renders the correct list type text', () => {
      createComponent({ activeId: 1, boardListType: 'assignee' });

      expect(wrapper.find('.js-list-label').text()).toBe('Assignee');
    });
  });
});
