import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import EpicLane from 'ee/boards/components/epic_lane.vue';
import IssuesLaneList from 'ee/boards/components/issues_lane_list.vue';
import { GlIcon } from '@gitlab/ui';
import getters from 'ee/boards/stores/getters';
import { mockEpic, mockListsWithModel, mockIssuesByListId, issues } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('EpicLane', () => {
  let wrapper;

  const createStore = () => {
    return new Vuex.Store({
      state: {
        issuesByListId: mockIssuesByListId,
        issues,
      },
      getters,
    });
  };

  const createComponent = (props = {}) => {
    const store = createStore();

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

    it('icon aria label is Opened when epic is opened', () => {
      expect(wrapper.find(GlIcon).attributes('aria-label')).toEqual('Opened');
    });

    it('icon aria label is Closed when epic is closed', () => {
      createComponent({ epic: { ...mockEpic, state: 'closed' } });
      expect(wrapper.find(GlIcon).attributes('aria-label')).toEqual('Closed');
    });

    it('displays count of issues in epic which belong to board', () => {
      expect(wrapper.find('[data-testid="epic-lane-issue-count"]').text()).toContain(2);
    });

    it('displays 2 icons', () => {
      expect(wrapper.findAll(GlIcon)).toHaveLength(2);
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

      wrapper.find('[data-testid="epic-lane-chevron"]').vm.$emit('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.findAll(IssuesLaneList)).toHaveLength(0);
        expect(wrapper.vm.isExpanded).toBe(false);
      });
    });
  });
});
