import { GlDrawer } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import EpicBoardContentSidebar from 'ee_component/boards/components/epic_board_content_sidebar.vue';
import { stubComponent } from 'helpers/stub_component';
import BoardSidebarLabelsSelect from '~/boards/components/sidebar/board_sidebar_labels_select.vue';
import { ISSUABLE } from '~/boards/constants';
import { mockEpic } from '../mock_data';

describe('EpicBoardContentSidebar', () => {
  let wrapper;
  let store;

  const createStore = ({ mockGetters = {}, mockActions = {} } = {}) => {
    store = new Vuex.Store({
      state: {
        sidebarType: ISSUABLE,
        boardItems: { [mockEpic.id]: mockEpic },
        activeId: mockEpic.id,
        issuableType: 'epic',
      },
      getters: {
        activeBoardItem: () => {
          return mockEpic;
        },
        isSidebarOpen: () => true,
        ...mockGetters,
      },
      actions: mockActions,
    });
  };

  const createComponent = () => {
    wrapper = shallowMount(EpicBoardContentSidebar, {
      provide: {
        canUpdate: true,
        rootPath: '/',
        groupId: 1,
      },
      store,
      stubs: {
        GlDrawer: stubComponent(GlDrawer, {
          template: '<div><slot name="header"></slot><slot></slot></div>',
        }),
      },
    });
  };

  beforeEach(() => {
    createStore();
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
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
        boardItem: mockEpic,
        sidebarType: ISSUABLE,
      });
    });
  });
});
