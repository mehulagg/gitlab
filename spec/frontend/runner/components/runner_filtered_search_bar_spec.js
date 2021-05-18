import { GlFilteredSearch, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import RunnerFilteredSearchBar from '~/runner/components/runner_filtered_search_bar.vue';
import { PARAM_KEY_STATUS, PARAM_KEY_RUNNER_TYPE } from '~/runner/constants';
import FilteredSearch from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';

describe('RunnerList', () => {
  let wrapper;

  const findFilteredSearch = () => wrapper.findComponent(FilteredSearch);
  const findGlFilteredSearch = () => wrapper.findComponent(GlFilteredSearch);
  const findSortOptions = () => wrapper.findAllComponents(GlDropdownItem);

  const mockDefaultSort = 'CREATED_DESC';
  const mockOtherSort = 'CONTACTED_DESC';
  const mockFilters = [
    { type: PARAM_KEY_STATUS, value: { data: 'ACTIVE', operator: '=' } },
    { type: 'filtered-search-term', value: { data: '' } },
  ];

  const createComponent = ({ props = {}, options = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(RunnerFilteredSearchBar, {
        propsData: {
          value: {
            filters: [],
            sort: mockDefaultSort,
          },
          ...props,
        },
        attrs: { namespace: 'runners' },
        stubs: {
          FilteredSearch,
          GlFilteredSearch,
          GlDropdown,
          GlDropdownItem,
        },
        ...options,
      }),
    );
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('binds a namespace to the filtered search', () => {
    expect(findFilteredSearch().props('namespace')).toBe('runners');
  });

  it('sets sorting options', () => {
    const SORT_OPTIONS_COUNT = 2;

    expect(findSortOptions()).toHaveLength(SORT_OPTIONS_COUNT);
    expect(findSortOptions().at(0).text()).toBe('Created date');
    expect(findSortOptions().at(1).text()).toBe('Last contact');
  });

  it('sets tokens', () => {
    const tokens = findFilteredSearch().props('tokens');

    // status filter token
    expect(tokens[0].type).toEqual(PARAM_KEY_STATUS);
    expect(tokens[0].options).toEqual(expect.any(Array));

    // runner filter type
    expect(tokens[1].type).toEqual(PARAM_KEY_RUNNER_TYPE);
    expect(tokens[1].options).toEqual(expect.any(Array));
  });

  it('fails validation for v-model with the wrong shape', () => {
    expect(() => {
      createComponent({ props: { value: { filters: 'wrong_filters', sort: 'sort' } } });
    }).toThrow('Invalid prop: custom validator check failed');

    expect(() => {
      createComponent({ props: { value: { sort: 'sort' } } });
    }).toThrow('Invalid prop: custom validator check failed');
  });

  describe('when a search is preselected', () => {
    beforeEach(() => {
      createComponent({
        props: {
          value: {
            sort: mockOtherSort,
            filters: mockFilters,
          },
        },
      });
    });

    it('filter values are shown', () => {
      expect(findGlFilteredSearch().props('value')).toEqual(mockFilters);
    });

    it('sort option is selected', () => {
      expect(
        findSortOptions()
          .filter((w) => w.props('isChecked'))
          .at(0)
          .text(),
      ).toEqual('Last contact');
    });
  });

  it('when the user sets a filter, the "search" is emitted with filters', () => {
    findGlFilteredSearch().vm.$emit('input', mockFilters);
    findGlFilteredSearch().vm.$emit('submit');

    expect(wrapper.emitted('input')[0]).toEqual([
      {
        filters: mockFilters,
        sort: mockDefaultSort,
      },
    ]);
  });

  it('when the user sets a sorting method, the "search" is emitted with the sort', () => {
    findSortOptions().at(1).vm.$emit('click');

    expect(wrapper.emitted('input')[0]).toEqual([
      {
        filters: [],
        sort: mockOtherSort,
      },
    ]);
  });
});
