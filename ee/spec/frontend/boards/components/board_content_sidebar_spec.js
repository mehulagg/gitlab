import { GlDrawer } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import BoardContentSidebar from 'ee_component/boards/components/board_content_sidebar.vue';
import BoardSidebarEpicSelect from 'ee_component/boards/components/sidebar/board_sidebar_epic_select.vue';
import BoardSidebarWeightInput from 'ee_component/boards/components/sidebar/board_sidebar_weight_input.vue';
import SidebarIterationWidget from 'ee_component/sidebar/components/sidebar_iteration_widget';
import { stubComponent } from 'helpers/stub_component';
import { ISSUABLE, issuableTypes } from '~/boards/constants';
import { mockIssue, mockIssueGroupPath, mockIssueProjectPath } from '../mock_data';

describe('ee/BoardContentSidebar', () => {
  let wrapper;
  let store;

  const createStore = ({ mockGetters = {}, mockActions = {} } = {}) => {
    store = new Vuex.Store({
      state: {
        sidebarType: ISSUABLE,
        issues: { [mockIssue.id]: { ...mockIssue, epic: null } },
        activeId: mockIssue.id,
        issuableType: issuableTypes.issue,
      },
      getters: {
        activeBoardItem: () => {
          return { ...mockIssue, epic: null };
        },
        projectPathForActiveIssue: () => mockIssueProjectPath,
        groupPathForActiveIssue: () => mockIssueGroupPath,
        isSidebarOpen: () => true,
        ...mockGetters,
      },
      actions: mockActions,
    });
  };

  const createComponent = () => {
    /*
      Dynamically imported components (in our case ee imports)
      aren't stubbed automatically in VTU v1:
      https://github.com/vuejs/vue-test-utils/issues/1279.

      This requires us to additionally mock apollo or vuex stores.
    */
    wrapper = shallowMount(BoardContentSidebar, {
      provide: {
        canUpdate: true,
        rootPath: '/',
        groupId: 1,
        weightFeatureAvailable: true,
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
            currentIteration: {
              loading: false,
            },
            iterations: {
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

  it('renders SidebarIterationWidget', () => {
    expect(wrapper.find(SidebarIterationWidget).exists()).toBe(true);
  });

  it('renders BoardSidebarEpicSelect', () => {
    expect(wrapper.find(BoardSidebarEpicSelect).exists()).toBe(true);
  });

  it('renders BoardSidebarWeightInput', () => {
    expect(wrapper.find(BoardSidebarWeightInput).exists()).toBe(true);
  });
});
