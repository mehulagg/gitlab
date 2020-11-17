import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import EpicLane from 'ee/boards/components/epic_lane.vue';
import IssuesLaneList from 'ee/boards/components/issues_lane_list.vue';
import { GlIcon, GlLoadingIcon } from '@gitlab/ui';
import getters from 'ee/boards/stores/getters';
import { mockEpic, mockListsWithModel, mockIssuesByListId, issues } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('EpicLane', () => {
  let wrapper;

  const findByTestId = testId => wrapper.find(`[data-testid="${testId}"]`);

  const updateBoardEpicUserPreferencesSpy = jest.fn();

  const createStore = ({ isLoading = false, issuesByListId = mockIssuesByListId }) => {
    return new Vuex.Store({
      actions: {
        fetchIssuesForEpic: jest.fn(),
        updateBoardEpicUserPreferences: updateBoardEpicUserPreferencesSpy,
      },
      state: {
        issuesByListId,
        issues,
        epicsFlags: {
          [mockEpic.id]: { isLoading },
        },
      },
      getters,
    });
  };

  const createComponent = ({
    props = {},
    isLoading = false,
    issuesByListId = mockIssuesByListId,
  } = {}) => {
    const store = createStore({ isLoading, issuesByListId });

    const defaultProps = {
      epic: mockEpic,
      lists: mockListsWithModel,
      disabled: false,
    };

    wrapper = shallowMount(EpicLane, {
      localVue,
      propsData: {
        ...defaultProps,
        ...props,
      },
      store,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('displays count of issues in epic which belong to board', () => {
      expect(findByTestId('epic-lane-issue-count').text()).toContain(2);
    });

    it('displays 1 icon', () => {
      expect(wrapper.findAll(GlIcon)).toHaveLength(1);
    });

    it('displays epic title', () => {
      expect(wrapper.text()).toContain(mockEpic.title);
    });

    it('renders one IssuesLaneList component per list passed in props', () => {
      expect(wrapper.findAll(IssuesLaneList)).toHaveLength(wrapper.props('lists').length);
    });

    it('hides issues when collapsing', () => {
      expect(wrapper.findAll(IssuesLaneList)).toHaveLength(wrapper.props('lists').length);
      expect(wrapper.vm.isCollapsed).toBe(false);

      findByTestId('epic-lane-chevron').vm.$emit('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.findAll(IssuesLaneList)).toHaveLength(0);
        expect(wrapper.vm.isCollapsed).toBe(true);
      });
    });

    it('does not display loading icon when issues are not loading', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    });

    it('displays loading icon and hides issues count when issues are loading', () => {
      createComponent({ isLoading: true });
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
      expect(findByTestId('epic-lane-issue-count').exists()).toBe(false);
    });

    it('invokes `updateBoardEpicUserPreferences` method on collapse', () => {
      const collapsedValue = false;

      expect(wrapper.vm.isCollapsed).toBe(collapsedValue);

      findByTestId('epic-lane-chevron').vm.$emit('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(updateBoardEpicUserPreferencesSpy).toHaveBeenCalled();

        const payload = updateBoardEpicUserPreferencesSpy.mock.calls[0][1];

        expect(payload).toEqual({
          collapsed: !collapsedValue,
          epicId: mockEpic.id,
        });

        expect(wrapper.vm.isCollapsed).toBe(true);
      });
    });

    it('does not render when issuesCount is 0', () => {
      createComponent({ issuesByListId: {} });
      expect(findByTestId('board-epic-lane').exists()).toBe(false);
    });
  });
});
