import { GlIcon } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Draggable from 'vuedraggable';
import Vuex from 'vuex';
import EpicLane from 'ee/boards/components/epic_lane.vue';
import EpicsSwimlanes from 'ee/boards/components/epics_swimlanes.vue';
import IssueLaneList from 'ee/boards/components/issues_lane_list.vue';
import getters from 'ee/boards/stores/getters';
import BoardListHeader from 'ee_else_ce/boards/components/board_list_header.vue';
import { mockLists, mockEpics, mockIssuesByListId, issues } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('EpicsSwimlanes', () => {
  let wrapper;

  const createStore = () => {
    return new Vuex.Store({
      state: {
        epics: mockEpics,
        issuesByListId: mockIssuesByListId,
        issues,
        pageInfoByListId: {
          'gid://gitlab/List/1': {},
          'gid://gitlab/List/2': {},
        },
        listsFlags: {
          'gid://gitlab/List/1': {
            unassignedIssuesCount: 1,
          },
          'gid://gitlab/List/2': {
            unassignedIssuesCount: 1,
          },
        },
      },
      getters,
    });
  };

  const createComponent = (props = {}) => {
    const store = createStore();
    const defaultProps = {
      lists: mockLists,
      disabled: false,
    };

    wrapper = shallowMount(EpicsSwimlanes, {
      localVue,
      propsData: { ...defaultProps, ...props },
      store,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('computed', () => {
    describe('treeRootWrapper', () => {
      describe('when canAdminList prop is true', () => {
        beforeEach(() => {
          createComponent({ canAdminList: true });
        });

        it('should return Draggable reference when canAdminList prop is true', () => {
          expect(wrapper.find(Draggable).exists()).toBe(true);
        });
      });

      describe('when canAdminList prop is false', () => {
        beforeEach(() => {
          createComponent();
        });

        it('should not return Draggable reference when canAdminList prop is false', () => {
          expect(wrapper.find(Draggable).exists()).toBe(false);
        });
      });
    });
  });

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('displays BoardListHeader components for lists', () => {
      expect(wrapper.findAll(BoardListHeader)).toHaveLength(2);
    });

    it('displays EpicLane components for epic', () => {
      expect(wrapper.findAll(EpicLane)).toHaveLength(5);
    });

    it('displays IssueLaneList component', () => {
      expect(wrapper.find(IssueLaneList).exists()).toBe(true);
    });

    it('displays issues icon and count for unassigned issue', () => {
      expect(wrapper.find(GlIcon).props('name')).toEqual('issues');
      expect(wrapper.find('[data-testid="issues-lane-issue-count"]').text()).toEqual('2');
    });

    it('makes non preset lists draggable', () => {
      expect(wrapper.findAll('[data-testid="board-header-container"]').at(1).classes()).toContain(
        'is-draggable',
      );
    });

    it('does not make preset lists draggable', () => {
      expect(
        wrapper.findAll('[data-testid="board-header-container"]').at(0).classes(),
      ).not.toContain('is-draggable');
    });
  });
});
