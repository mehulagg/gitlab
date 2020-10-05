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

  const createStore = isLoading => {
    return new Vuex.Store({
      actions: {
        fetchIssuesForEpic: jest.fn(),
      },
      state: {
        issuesByListId: mockIssuesByListId,
        issues,
        epicsFlags: {
          [mockEpic.id]: { isLoading },
        },
      },
      getters,
    });
  };

  const createComponent = ({ props = {}, isLoading = false } = {}) => {
    const store = createStore(isLoading);

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
      expect(wrapper.vm.isExpanded).toBe(true);

      findByTestId('epic-lane-chevron').vm.$emit('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.findAll(IssuesLaneList)).toHaveLength(0);
        expect(wrapper.vm.isExpanded).toBe(false);
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
  });
});
