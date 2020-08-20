import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import FilterBar, { prepareTokens } from 'ee/analytics/cycle_analytics/components/filter_bar.vue';
import initialFiltersState from 'ee/analytics/cycle_analytics/store/modules/filters/state';
import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import { filterMilestones, filterLabels } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

const milestoneTokenType = 'milestone';
const labelsTokenType = 'labels';
const authorTokenType = 'author';
const assigneesTokenType = 'assignees';

describe('Filter bar', () => {
  let wrapper;
  let store;

  let setFiltersMock;

  const createStore = (initialState = {}) => {
    setFiltersMock = jest.fn();

    return new Vuex.Store({
      modules: {
        filters: {
          namespaced: true,
          state: {
            ...initialFiltersState(),
            ...initialState,
          },
          actions: {
            setFilters: setFiltersMock,
          },
        },
      },
    });
  };

  const createComponent = initialStore =>
    shallowMount(FilterBar, {
      localVue,
      store: initialStore,
      propsData: {
        groupPath: 'foo',
      },
    });

  afterEach(() => {
    wrapper.destroy();
  });

  const selectedMilestone = [filterMilestones[0]];
  const selectedLabel = [filterLabels[0]];

  const findFilteredSearch = () => wrapper.find(FilteredSearchBar);
  const getSearchToken = type =>
    findFilteredSearch()
      .props('tokens')
      .find(token => token.type === type);

  describe('default', () => {
    beforeEach(() => {
      store = createStore();
      wrapper = createComponent(store);
    });

    it('renders FilteredSearchBar component', () => {
      expect(findFilteredSearch().exists()).toBe(true);
    });
  });

  describe('when the state has data', () => {
    beforeEach(() => {
      store = createStore({
        milestones: { data: selectedMilestone },
        labels: { data: selectedLabel },
        authors: { data: [] },
        assignees: { data: [] },
      });
      wrapper = createComponent(store);
    });

    it('displays the milestone and label token', () => {
      const tokens = findFilteredSearch().props('tokens');

      expect(tokens).toHaveLength(4);
      expect(tokens[0].type).toBe(milestoneTokenType);
      expect(tokens[1].type).toBe(labelsTokenType);
      expect(tokens[2].type).toBe(authorTokenType);
      expect(tokens[3].type).toBe(assigneesTokenType);
    });

    it('provides the initial milestone token', () => {
      const { initialMilestones: milestoneToken } = getSearchToken(milestoneTokenType);

      expect(milestoneToken).toHaveLength(selectedMilestone.length);
    });

    it('provides the initial label token', () => {
      const { initialLabels: labelToken } = getSearchToken(labelsTokenType);

      expect(labelToken).toHaveLength(selectedLabel.length);
    });
  });

  describe('when the user interacts', () => {
    beforeEach(() => {
      store = createStore({
        milestones: { data: filterMilestones },
        labels: { data: filterLabels },
      });
      wrapper = createComponent(store);
    });

    it('clicks on the search button, setFilters is dispatched', () => {
      findFilteredSearch().vm.$emit('onFilter', [
        { type: 'milestone', value: { data: selectedMilestone[0].title, operator: '=' } },
        { type: 'labels', value: { data: selectedLabel[0].title, operator: '=' } },
      ]);

      expect(setFiltersMock).toHaveBeenCalledWith(expect.anything(), {
        selectedLabels: [selectedLabel[0].title],
        selectedMilestone: selectedMilestone[0].title,
        selectedAssignees: [],
        selectedAuthor: null,
      });
    });

    it('removes wrapping double quotes from the data and dispatches setFilters', () => {
      findFilteredSearch().vm.$emit('onFilter', [
        { type: 'milestone', value: { data: '"milestone with spaces"', operator: '=' } },
      ]);

      expect(setFiltersMock).toHaveBeenCalledWith(expect.anything(), {
        selectedMilestone: 'milestone with spaces',
        selectedLabels: [],
        selectedAssignees: [],
        selectedAuthor: null,
      });
    });

    it('removes wrapping single quotes from the data and dispatches setFilters', () => {
      findFilteredSearch().vm.$emit('onFilter', [
        { type: 'milestone', value: { data: "'milestone with spaces'", operator: '=' } },
      ]);

      expect(setFiltersMock).toHaveBeenCalledWith(expect.anything(), {
        selectedMilestone: 'milestone with spaces',
        selectedLabels: [],
        selectedAssignees: [],
        selectedAuthor: null,
      });
    });

    it('does not remove inner double quotes from the data and dispatches setFilters ', () => {
      findFilteredSearch().vm.$emit('onFilter', [
        { type: 'milestone', value: { data: 'milestone "with" spaces', operator: '=' } },
      ]);

      expect(setFiltersMock).toHaveBeenCalledWith(expect.anything(), {
        selectedMilestone: 'milestone "with" spaces',
        selectedAssignees: [],
        selectedAuthor: null,
        selectedLabels: [],
      });
    });
  });

  describe('prepareTokens', () => {
    describe('with empty data', () => {
      it('returns an empty array', () => {
        expect(prepareTokens()).toEqual([]);
        expect(prepareTokens({})).toEqual([]);
        expect(prepareTokens({ milestone: null, author: null, assignees: [], labels: [] })).toEqual(
          [],
        );
      });
    });

    it.each`
      token          | value                     | result
      ${'milestone'} | ${'v1.0'}                 | ${[{ type: 'milestone', value: { data: 'v1.0' } }]}
      ${'author'}    | ${'mr.popo'}              | ${[{ type: 'author', value: { data: 'mr.popo' } }]}
      ${'labels'}    | ${['z-fighters']}         | ${[{ type: 'labels', value: { data: 'z-fighters' } }]}
      ${'assignees'} | ${['krillin', 'piccolo']} | ${[{ type: 'assignees', value: { data: 'krillin' } }, { type: 'assignees', value: { data: 'piccolo' } }]}
    `('with $token=$value sets the $token key', ({ token, value, result }) => {
      const res = prepareTokens({ [token]: value });
      expect(res).toEqual(result);
    });
  });
});
