import Vuex from 'vuex';
import { createLocalVue, shallowMount, mount } from '@vue/test-utils';
import Draggable from 'vuedraggable';
import EpicsSwimlanes from 'ee/boards/components/epics_swimlanes.vue';
import BoardListHeader from 'ee_else_ce/boards/components/board_list_header.vue';
import EpicLane from 'ee/boards/components/epic_lane.vue';
import IssueLaneList from 'ee/boards/components/issues_lane_list.vue';
import getters from 'ee/boards/stores/getters';
import { GlIcon } from '@gitlab/ui';
import { mockListsWithModel, mockEpics, mockIssuesByListId, issues } from '../mock_data';

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

  const createComponent = (props = {}, method = shallowMount) => {
    const store = createStore();
    const defaultProps = {
      lists: mockListsWithModel,
      disabled: false,
    };

    wrapper = method(EpicsSwimlanes, {
      localVue,
      propsData: { ...defaultProps, ...props },
      store,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

<<<<<<< Updated upstream
  describe('computed', () => {
    describe('treeRootWrapper', () => {
      describe('when canAdminList prop is true', () => {
        beforeEach(() => {
          createComponent({ canAdminList: true });
        });

        it('should return Draggable reference when canAdminList prop is true', () => {
          expect(wrapper.find(Draggable).exists()).toBe(true);
        });
=======
  fdescribe('treeRootWrapper', () => {

    describe('when canAdminList prop is true', () => {
      beforeEach(() => {
        createComponent({ canAdminList: true });
      });

      it('should return Draggable reference when canAdminList prop is true', () => {
        expect(wrapper.find(Draggable).exists()).toBe(true)
>>>>>>> Stashed changes
      });
    });

<<<<<<< Updated upstream
      describe('when canAdminList prop is false', () => {
        beforeEach(() => {
          createComponent();
        });
=======

    describe('when canAdminList prop is false', () => {
      it('should not return Draggable reference when canAdminList prop is false', () => {
        expect(wrapper.find(Draggable).exists()).toBe(false)
      });
    });

  });

  describe('treeRootOptions', () => {
    it('should return object containing Vue.Draggable config extended from `defaultSortableConfig` when canAdminList prop is true', () => {
      wrapper.setProps({ canAdminList: true });

      expect(wrapper.vm.treeRootOptions).toEqual(
        expect.objectContaining({
          animation: 200,
          forceFallback: true,
          fallbackClass: 'is-dragging',
          fallbackOnBody: false,
          ghostClass: 'is-ghost',
          group: 'board-swimlanes',
          tag: DRAGGABLE_TAG,
          draggable: '.is-draggable',
          'ghost-class': 'swimlane-header-drag-active',
          value: mockListsWithModel,
        }),
      );
    });

    it('should return an empty object when canAdminList prop is false', () => {
      expect(wrapper.vm.treeRootOptions).toEqual(expect.objectContaining({}));
    });
  });



  describe('computed', () => {


    describe('treeRootOptions', () => {
      it('should return object containing Vue.Draggable config extended from `defaultSortableConfig` when canAdminList prop is true', () => {
        wrapper.setProps({ canAdminList: true });

        expect(wrapper.vm.treeRootOptions).toEqual(
          expect.objectContaining({
            animation: 200,
            forceFallback: true,
            fallbackClass: 'is-dragging',
            fallbackOnBody: false,
            ghostClass: 'is-ghost',
            group: 'board-swimlanes',
            tag: DRAGGABLE_TAG,
            draggable: '.is-draggable',
            'ghost-class': 'swimlane-header-drag-active',
            value: mockListsWithModel,
          }),
        );
      });
>>>>>>> Stashed changes

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
      expect(
        wrapper
          .findAll('[data-testid="board-header-container"]')
          .at(1)
          .classes(),
      ).toContain('is-draggable');
    });

    it('does not make preset lists draggable', () => {
      expect(
        wrapper
          .findAll('[data-testid="board-header-container"]')
          .at(0)
          .classes(),
      ).not.toContain('is-draggable');
    });
  });
});
