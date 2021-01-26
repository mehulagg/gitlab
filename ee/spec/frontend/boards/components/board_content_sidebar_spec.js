import { GlDrawer } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import BoardContentSidebar from 'ee_component/boards/components/board_content_sidebar.vue';
import { stubComponent } from 'helpers/stub_component';
import waitForPromises from 'helpers/wait_for_promises';
import BoardAssigneeDropdown from '~/boards/components/board_assignee_dropdown.vue';
import BoardSidebarLabelsSelect from '~/boards/components/sidebar/board_sidebar_labels_select.vue';
import BoardSidebarIssueTitle from '~/boards/components/sidebar/board_sidebar_issue_title.vue';
import BoardSidebarDueDate from '~/boards/components/sidebar/board_sidebar_due_date.vue';
import BoardSidebarSubscription from '~/boards/components/sidebar/board_sidebar_subscription.vue';
import BoardSidebarMilestoneSelect from '~/boards/components/sidebar/board_sidebar_milestone_select.vue';
import { ISSUABLE } from '~/boards/constants';
import { createStore } from '~/boards/stores';

describe('ee/BoardContentSidebar', () => {
  let wrapper;
  let store;

  const createComponent = () => {
    wrapper = shallowMount(BoardContentSidebar, {
      provide: {
        canUpdate: true,
        rootPath: '/',
        groupId: '#',
      },
      store,
      stubs: {
        GlDrawer: stubComponent(GlDrawer, {
          template: '<div><slot name="header"></slot><slot></slot></div>',
        }),
      },
      mocks: {
        $apollo: {
          queries: {
            participants: {
              loading: false,
            },
          },
        },
      },
    });
  };

  beforeEach(() => {
    store = createStore();
    store.state.sidebarType = ISSUABLE;
    store.state.issues = { 1: { title: 'One', referencePath: 'path', assignees: [] } };
    store.state.activeId = '1';

    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('confirms we render GlDrawer', () => {
    expect(wrapper.find(GlDrawer).exists()).toBe(true);
  });

  it('applies an open attribute', () => {
    expect(wrapper.find(GlDrawer).props('open')).toBe(true);
  });

  it('renders BoardAssigneeDropdown', () => {
    expect(wrapper.find(BoardAssigneeDropdown).exists()).toBe(true);
  });

  it('renders BoardSidebarLabelsSelect', () => {
    expect(wrapper.find(BoardSidebarLabelsSelect).exists()).toBe(true);
  });

  it('renders BoardSidebarIssueTitle', () => {
    expect(wrapper.find(BoardSidebarIssueTitle).exists()).toBe(true);
  });

  it('renders BoardSidebarDueDate', () => {
    expect(wrapper.find(BoardSidebarDueDate).exists()).toBe(true);
  });

  it('renders BoardSidebarSubscription', () => {
    expect(wrapper.find(BoardSidebarSubscription).exists()).toBe(true);
  });

  it('renders BoardSidebarMilestoneSelect', () => {
    expect(wrapper.find(BoardSidebarMilestoneSelect).exists()).toBe(true);
  });

  describe('when we emit close', () => {
    it('hides GlDrawer', async () => {
      expect(wrapper.find(GlDrawer).props('open')).toBe(true);

      wrapper.find(GlDrawer).vm.$emit('close');

      await waitForPromises();

      expect(wrapper.find(GlDrawer).exists()).toBe(false);
    });
  });
});
