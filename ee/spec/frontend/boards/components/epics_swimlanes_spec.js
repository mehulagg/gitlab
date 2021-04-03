import { GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import VirtualList from 'vue-virtual-scroll-list';
import Draggable from 'vuedraggable';
import Vuex from 'vuex';
import { calculateSwimlanesBufferSize } from 'ee/boards/boards_util';
import EpicLane from 'ee/boards/components/epic_lane.vue';
import EpicsSwimlanes from 'ee/boards/components/epics_swimlanes.vue';
import IssueLaneList from 'ee/boards/components/issues_lane_list.vue';
import SwimlanesLoadingSkeleton from 'ee/boards/components/swimlanes_loading_skeleton.vue';
import { EPIC_LANE_BASE_HEIGHT } from 'ee/boards/constants';
import getters from 'ee/boards/stores/getters';
import BoardListHeader from 'ee_else_ce/boards/components/board_list_header.vue';
import { mockLists, mockEpics, mockIssuesByListId, issues } from '../mock_data';

Vue.use(Vuex);
jest.mock('ee/boards/boards_util');

describe('EpicsSwimlanes', () => {
  let wrapper;

  const fetchItemsForListSpy = jest.fn();

  const createStore = ({
    epicLanesFetchInProgress = false,
    listItemsFetchInProgress = false,
  } = {}) => {
    return new Vuex.Store({
      state: {
        epics: mockEpics,
        boardItemsByListId: mockIssuesByListId,
        boardItems: issues,
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
        epicsSwimlanesFetchInProgress: {
          epicLanesFetchInProgress,
          listItemsFetchInProgress,
        },
      },
      getters,
      actions: {
        fetchItemsForList: fetchItemsForListSpy,
      },
    });
  };

  const createComponent = ({
    canAdminList = false,
    swimlanesBufferedRendering = false,
    epicLanesFetchInProgress = false,
    listItemsFetchInProgress = false,
  } = {}) => {
    const store = createStore({ epicLanesFetchInProgress, listItemsFetchInProgress });
    const defaultProps = {
      lists: mockLists,
      disabled: false,
    };

    wrapper = shallowMount(EpicsSwimlanes, {
      propsData: { ...defaultProps, canAdminList },
      store,
      provide: {
        glFeatures: { swimlanesBufferedRendering },
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('calls fetchItemsForList on mounted', () => {
    createComponent();
    expect(fetchItemsForListSpy).toHaveBeenCalled();
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
      expect(wrapper.findAll(BoardListHeader)).toHaveLength(4);
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

  describe('Loading skeleton', () => {
    it.each`
      epicLanesFetchInProgress | listItemsFetchInProgress | expected
      ${true}                  | ${true}                  | ${true}
      ${false}                 | ${true}                  | ${false}
      ${true}                  | ${false}                 | ${false}
      ${false}                 | ${false}                 | ${false}
    `(
      'loading is $expected when epicLanesFetchInProgress is $epicLanesFetchInProgress and listItemsFetchInProgress is $listItemsFetchInProgress',
      ({ epicLanesFetchInProgress, listItemsFetchInProgress, expected }) => {
        createComponent({ epicLanesFetchInProgress, listItemsFetchInProgress });

        expect(wrapper.find(SwimlanesLoadingSkeleton).exists()).toBe(expected);
      },
    );
  });

  describe('when swimlanesBufferedRendering is true', () => {
    const bufferSize = 100;

    beforeEach(() => {
      calculateSwimlanesBufferSize.mockReturnValueOnce(bufferSize);
      createComponent({ swimlanesBufferedRendering: true });
    });

    it('renders virtual-list', () => {
      const virtualList = wrapper.find(VirtualList);
      const scrollableContainer = wrapper.find({ ref: 'scrollableContainer' }).element;

      expect(calculateSwimlanesBufferSize).toHaveBeenCalledWith(wrapper.element.offsetTop);
      expect(virtualList.props()).toMatchObject({
        remain: bufferSize,
        bench: bufferSize,
        item: EpicLane,
        size: EPIC_LANE_BASE_HEIGHT,
        itemcount: mockEpics.length,
        itemprops: expect.any(Function),
      });

      expect(virtualList.props().scrollelement).toBe(scrollableContainer);
    });
  });
});
