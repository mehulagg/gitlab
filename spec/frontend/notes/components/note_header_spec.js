import { shallowMount, createLocalVue } from '@vue/test-utils';
import { nextTick } from 'vue';
import Vuex from 'vuex';
import NoteHeader from '~/notes/components/note_header.vue';
import GitlabTeamMemberBadge from '~/vue_shared/components/user_avatar/badges/gitlab_team_member_badge.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

const actions = {
  setTargetNoteHash: jest.fn(),
};

describe('NoteHeader component', () => {
  let wrapper;

  const findActionsWrapper = () => wrapper.find({ ref: 'discussionActions' });
  const findChevronIcon = () => wrapper.find({ ref: 'chevronIcon' });
  const findActionText = () => wrapper.find({ ref: 'actionText' });
  const findTimestampLink = () => wrapper.find({ ref: 'noteTimestampLink' });
  const findTimestamp = () => wrapper.find({ ref: 'noteTimestamp' });
  const findConfidentialIndicator = () => wrapper.find({ ref: 'confidentialIndicator' });
  const findSpinner = () => wrapper.find({ ref: 'spinner' });

  const author = {
    avatar_url: null,
    id: 1,
    name: 'Root',
    path: '/root',
    state: 'active',
    username: 'root',
  };

  const createComponent = props => {
    wrapper = shallowMount(NoteHeader, {
      localVue,
      store: new Vuex.Store({
        actions,
      }),
      propsData: { ...props },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('does not render discussion actions when includeToggle is false', () => {
    createComponent({
      includeToggle: false,
    });

    expect(findActionsWrapper().exists()).toBe(false);
  });

  describe('when includes a toggle', () => {
    it('renders discussion actions', () => {
      createComponent({
        includeToggle: true,
      });

      expect(findActionsWrapper().exists()).toBe(true);
    });

    it('emits toggleHandler event on button click', () => {
      createComponent({
        includeToggle: true,
      });

      wrapper.find('.note-action-button').trigger('click');
      expect(wrapper.emitted('toggleHandler')).toBeDefined();
      expect(wrapper.emitted('toggleHandler')).toHaveLength(1);
    });

    it('has chevron-up icon if expanded prop is true', () => {
      createComponent({
        includeToggle: true,
        expanded: true,
      });

      expect(findChevronIcon().classes()).toContain('fa-chevron-up');
    });

    it('has chevron-down icon if expanded prop is false', () => {
      createComponent({
        includeToggle: true,
        expanded: false,
      });

      expect(findChevronIcon().classes()).toContain('fa-chevron-down');
    });
  });

  it('renders an author link if author is passed to props', () => {
    createComponent({ author });

    expect(wrapper.find('.js-user-link').exists()).toBe(true);
  });

  it('renders deleted user text if author is not passed as a prop', () => {
    createComponent();

    expect(wrapper.text()).toContain('A deleted user');
  });

  it('does not render created at information if createdAt is not passed as a prop', () => {
    createComponent();

    expect(findActionText().exists()).toBe(false);
    expect(findTimestampLink().exists()).toBe(false);
  });

  describe('when createdAt is passed as a prop', () => {
    it('renders action text and a timestamp', () => {
      createComponent({
        createdAt: '2017-08-02T10:51:58.559Z',
        noteId: 123,
      });

      expect(findActionText().exists()).toBe(true);
      expect(findTimestampLink().exists()).toBe(true);
    });

    it('renders correct actionText if passed', () => {
      createComponent({
        createdAt: '2017-08-02T10:51:58.559Z',
        actionText: 'Test action text',
      });

      expect(findActionText().text()).toBe('Test action text');
    });

    it('calls an action when timestamp is clicked', () => {
      createComponent({
        createdAt: '2017-08-02T10:51:58.559Z',
        noteId: 123,
      });
      findTimestampLink().trigger('click');

      expect(actions.setTargetNoteHash).toHaveBeenCalled();
    });
  });

  test.each`
    props                                                   | expected | message1            | message2
    ${{ author: { ...author, is_gitlab_employee: true } }}  | ${true}  | ${'renders'}        | ${'true'}
    ${{ author: { ...author, is_gitlab_employee: false } }} | ${false} | ${"doesn't render"} | ${'false'}
    ${{ author }}                                           | ${false} | ${"doesn't render"} | ${'undefined'}
  `(
    '$message1 GitLab team member badge when `is_gitlab_employee` is $message2',
    ({ props, expected }) => {
      createComponent(props);

      expect(wrapper.find(GitlabTeamMemberBadge).exists()).toBe(expected);
    },
  );

  describe('loading spinner', () => {
    it('shows spinner when showSpinner is true', () => {
      createComponent();
      expect(findSpinner().exists()).toBe(true);
    });

    it('does not show spinner when showSpinner is false', () => {
      createComponent({ showSpinner: false });
      expect(findSpinner().exists()).toBe(false);
    });
  });

  describe('timestamp', () => {
    it('shows timestamp as a link if a noteId was provided', () => {
      createComponent({ createdAt: new Date().toISOString(), noteId: 123 });
      expect(findTimestampLink().exists()).toBe(true);
      expect(findTimestamp().exists()).toBe(false);
    });

    it('shows timestamp as plain text if a noteId was not provided', () => {
      createComponent({ createdAt: new Date().toISOString() });
      expect(findTimestampLink().exists()).toBe(false);
      expect(findTimestamp().exists()).toBe(true);
    });
  });

  describe('author username link', () => {
    it('proxies `mouseenter` event to author name link', () => {
      createComponent({ author });

      const dispatchEvent = jest.spyOn(wrapper.vm.$refs.authorNameLink, 'dispatchEvent');

      wrapper.find({ ref: 'authorUsernameLink' }).trigger('mouseenter');

      expect(dispatchEvent).toHaveBeenCalledWith(new Event('mouseenter'));
    });

    it('proxies `mouseleave` event to author name link', () => {
      createComponent({ author });

      const dispatchEvent = jest.spyOn(wrapper.vm.$refs.authorNameLink, 'dispatchEvent');

      wrapper.find({ ref: 'authorUsernameLink' }).trigger('mouseleave');

      expect(dispatchEvent).toHaveBeenCalledWith(new Event('mouseleave'));
    });
  });

  describe('when author status tooltip is opened', () => {
    it('removes `title` attribute from emoji to prevent duplicate tooltips', () => {
      createComponent({
        author: {
          ...author,
          status_tooltip_html:
            '"<span class="user-status-emoji has-tooltip" title="foo bar" data-html="true" data-placement="top"><gl-emoji title="basketball and hoop" data-name="basketball" data-unicode-version="6.0">🏀</gl-emoji></span>"',
        },
      });

      return nextTick().then(() => {
        const authorStatus = wrapper.find({ ref: 'authorStatus' });
        authorStatus.trigger('mouseenter');

        expect(authorStatus.find('gl-emoji').attributes('title')).toBeUndefined();
      });
    });
  });

  describe('when author username link is hovered', () => {
    it('toggles hover specific CSS classes on author name link', done => {
      createComponent({ author });

      const authorUsernameLink = wrapper.find({ ref: 'authorUsernameLink' });
      const authorNameLink = wrapper.find({ ref: 'authorNameLink' });

      authorUsernameLink.trigger('mouseenter');

      nextTick(() => {
        expect(authorNameLink.classes()).toContain('hover');
        expect(authorNameLink.classes()).toContain('text-underline');

        authorUsernameLink.trigger('mouseleave');

        nextTick(() => {
          expect(authorNameLink.classes()).not.toContain('hover');
          expect(authorNameLink.classes()).not.toContain('text-underline');

          done();
        });
      });
    });
  });

  describe('with confidentiality indicator', () => {
    it.each`
      status   | condition
      ${true}  | ${'shows'}
      ${false} | ${'hides'}
    `('$condition icon indicator when isConfidential is $status', ({ status }) => {
      createComponent({ isConfidential: status });
      expect(findConfidentialIndicator().exists()).toBe(status);
    });
  });
});
