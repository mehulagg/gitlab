import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import FilterSortContainer from '~/members/components/filter_sort/filter_sort_container.vue';
import MembersFilteredSearchBar from '~/members/components/filter_sort/members_filtered_search_bar.vue';
import SortDropdown from '~/members/components/filter_sort/sort_dropdown.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('FilterSortContainer', () => {
  let wrapper;

  const createComponent = state => {
    const store = new Vuex.Store({
      state: {
        tableSortableFields: ['account', 'granted', 'expires', 'maxRole'],
        filteredSearchBarOptions: {
          show: true,
          tokens: ['two_factor'],
          searchParam: 'search',
          placeholder: 'Filter members',
          recentSearchesStorageKey: 'group_members',
        },
        ...state,
      },
    });

    wrapper = shallowMount(FilterSortContainer, {
      localVue,
      store,
    });
  };

  describe('when `filteredSearchBarOptions.show` is `false` and `tableSortableFields` is empty', () => {
    it('renders nothing', () => {
      createComponent({
        tableSortableFields: [],
        filteredSearchBarOptions: {
          show: false,
        },
      });

      expect(wrapper.html()).toBe('');
    });
  });

  describe('when `filteredSearchBarOptions.show` is `true`', () => {
    it('renders `MembersFilteredSearchBar`', () => {
      createComponent({
        tableSortableFields: [],
        filteredSearchBarOptions: {
          show: true,
        },
      });

      expect(wrapper.find(MembersFilteredSearchBar).exists()).toBe(true);
    });
  });

  describe('when `tableSortableFields` is not empty', () => {
    it('renders `SortDropdown`', () => {
      createComponent({
        tableSortableFields: [],
        filteredSearchBarOptions: {
          show: true,
        },
      });

      expect(wrapper.find(SortDropdown).exists()).toBe(true);
    });
  });
});
