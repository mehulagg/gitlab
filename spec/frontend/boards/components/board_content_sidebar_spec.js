import { GlDrawer } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import { stubComponent } from 'helpers/stub_component';
import BoardContentSidebar from '~/boards/components/board_content_sidebar.vue';
import BoardSidebarDueDate from '~/boards/components/sidebar/board_sidebar_due_date.vue';
import BoardSidebarIssueTitle from '~/boards/components/sidebar/board_sidebar_issue_title.vue';
import BoardSidebarLabelsSelect from '~/boards/components/sidebar/board_sidebar_labels_select.vue';
import BoardSidebarMilestoneSelect from '~/boards/components/sidebar/board_sidebar_milestone_select.vue';
import BoardSidebarSubscription from '~/boards/components/sidebar/board_sidebar_subscription.vue';
import { ISSUABLE } from '~/boards/constants';
import { mockIssue } from '../mock_data';

describe('BoardContentSidebar', () => {
  let wrapper;
  let store;

  const createStore = ({ mockGetters = {}, mockActions = {} } = {}) => {
    store = new Vuex.Store({
      state: {
        sidebarType: ISSUABLE,
        issues: { [mockIssue.id]: mockIssue },
        activeId: mockIssue.id,
      },
      getters: {
        activeIssue: () => mockIssue,
        isSidebarOpen: () => true,
        ...mockGetters,
      },
      actions: mockActions,
    });
  };

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
    createStore();
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('confirms we render GlDrawer', () => {
    expect(wrapper.find(GlDrawer).exists()).toBe(true);
  });

  it('does not render GlDrawer when isSidebarOpen is false', () => {
    createStore({ mockGetters: { isSidebarOpen: () => false } });
    createComponent();

    expect(wrapper.find(GlDrawer).exists()).toBe(false);
  });

  it('applies an open attribute', () => {
    expect(wrapper.find(GlDrawer).props('open')).toBe(true);
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
    let toggleBoardItem;

    beforeEach(() => {
      toggleBoardItem = jest.fn();
      createStore({ mockActions: { toggleBoardItem } });
      createComponent();
    });

    it('calls toggleBoardItem with correct parameters', async () => {
      wrapper.find(GlDrawer).vm.$emit('close');

      expect(toggleBoardItem).toHaveBeenCalledTimes(1);
      expect(toggleBoardItem).toHaveBeenCalledWith(expect.any(Object), {
        boardItem: mockIssue,
        sidebarType: ISSUABLE,
      });
    });
  });
});
