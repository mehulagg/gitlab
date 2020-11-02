import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';

import JiraIssuesListRoot from 'ee/integrations/jira/issues_list/components/jira_issues_list_root.vue';

import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import IssuableList from '~/issuable_list/components/issuable_list_root.vue';
import { IssuableStates, IssuableListTabs, AvailableSortOptions } from '~/issuable_list/constants';

import { mockProvide, mockJiraIssues } from '../mock_data';

jest.mock('~/flash');
jest.mock('~/issuable_list/constants', () => ({
  DEFAULT_PAGE_SIZE: 2,
  IssuableStates: jest.requireActual('~/issuable_list/constants').IssuableStates,
  IssuableListTabs: jest.requireActual('~/issuable_list/constants').IssuableListTabs,
  AvailableSortOptions: jest.requireActual('~/issuable_list/constants').AvailableSortOptions,
}));

const createComponent = ({ provide = mockProvide, initialFilterParams = {} } = {}) =>
  shallowMount(JiraIssuesListRoot, {
    propsData: {
      initialFilterParams,
    },
    provide,
  });

describe('JiraIssuesListRoot', () => {
  const resolvedValue = {
    headers: {
      'x-page': 1,
      'x-total': 3,
    },
    data: mockJiraIssues,
  };
  let wrapper;
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  describe('computed', () => {
    describe('showPaginationControls', () => {
      it.each`
        issuesListLoading | issuesListLoadFailed | issues            | totalIssues              | returnValue
        ${true}           | ${false}             | ${[]}             | ${0}                     | ${false}
        ${false}          | ${true}              | ${[]}             | ${0}                     | ${false}
        ${false}          | ${false}             | ${mockJiraIssues} | ${mockJiraIssues.length} | ${true}
      `(
        'returns $returnValue when issuesListLoading is $issuesListLoading, issuesListLoadFailed is $issuesListLoadFailed, issues is $issues and totalIssues is $totalIssues',
        ({ issuesListLoading, issuesListLoadFailed, issues, totalIssues, returnValue }) => {
          wrapper.setData({
            issuesListLoading,
            issuesListLoadFailed,
            issues,
            totalIssues,
          });

          expect(wrapper.vm.showPaginationControls).toBe(returnValue);
        },
      );
    });

    describe('urlParams', () => {
      it('returns object containing `state`, `page`, `sort` and `search` properties', () => {
        wrapper.setData({
          currentState: 'closed',
          currentPage: 2,
          sortedBy: 'created_asc',
          filterParams: {
            search: 'foo',
          },
        });

        expect(wrapper.vm.urlParams).toMatchObject({
          state: 'closed',
          page: 2,
          sort: 'created_asc',
          search: 'foo',
        });
      });
    });
  });

  describe('methods', () => {
    describe('fetchIssues', () => {
      it('sets issuesListLoading to true and issuesListLoadFailed to false', () => {
        wrapper.vm.fetchIssues();

        expect(wrapper.vm.issuesListLoading).toBe(true);
        expect(wrapper.vm.issuesListLoadFailed).toBe(false);
      });

      it('calls `axios.get` with `issuesFetchPath` and query params', () => {
        jest.spyOn(axios, 'get').mockResolvedValue(resolvedValue);

        wrapper.vm.fetchIssues();

        expect(axios.get).toHaveBeenCalledWith(
          mockProvide.issuesFetchPath,
          expect.objectContaining({
            params: {
              with_labels_details: true,
              page: wrapper.vm.currentPage,
              per_page: wrapper.vm.$options.defaultPageSize,
              state: wrapper.vm.currentState,
              sort: wrapper.vm.sortedBy,
              search: wrapper.vm.filterParams.search,
            },
          }),
        );
      });

      it('sets `currentPage` and `totalIssues` from response headers and `issues` & `issuesCount` from response body when request is successful', async () => {
        jest.spyOn(axios, 'get').mockResolvedValue(resolvedValue);

        await wrapper.vm.fetchIssues();

        const firstIssue = convertObjectPropsToCamelCase(mockJiraIssues[0], { deep: true });

        expect(wrapper.vm.currentPage).toBe(resolvedValue.headers['x-page']);
        expect(wrapper.vm.totalIssues).toBe(resolvedValue.headers['x-total']);
        expect(wrapper.vm.issues[0]).toEqual({
          ...firstIssue,
          id: 31596,
          author: {
            ...firstIssue.author,
            id: 0,
          },
        });
        expect(wrapper.vm.issuesCount[IssuableStates.Opened]).toBe(3);
      });

      it('sets `issuesListLoadFailed` to true and calls `createFlash` when request fails', async () => {
        jest.spyOn(axios, 'get').mockRejectedValue({});

        await wrapper.vm.fetchIssues();

        expect(wrapper.vm.issuesListLoadFailed).toBe(true);
        expect(createFlash).toHaveBeenCalledWith({
          message: 'An error occurred while loading issues',
          captureError: true,
          error: expect.any(Object),
        });
      });

      it('sets `issuesListLoading` to false when request completes', async () => {
        jest.spyOn(axios, 'get').mockRejectedValue({});

        await wrapper.vm.fetchIssues();

        expect(wrapper.vm.issuesListLoading).toBe(false);
      });
    });

    describe('fetchIssuesBy', () => {
      it('sets provided prop value for given prop name and calls `fetchIssues`', () => {
        jest.spyOn(wrapper.vm, 'fetchIssues');

        wrapper.vm.fetchIssuesBy('currentPage', 2);

        expect(wrapper.vm.currentPage).toBe(2);
        expect(wrapper.vm.fetchIssues).toHaveBeenCalled();
      });
    });
  });

  describe('template', () => {
    const getIssuableList = () => wrapper.find(IssuableList);

    it('renders issuable-list component', async () => {
      wrapper.setData({
        filterParams: {
          search: 'foo',
        },
      });

      await wrapper.vm.$nextTick();

      expect(getIssuableList().exists()).toBe(true);
      expect(getIssuableList().props()).toMatchObject({
        namespace: mockProvide.projectFullPath,
        tabs: IssuableListTabs,
        currentTab: 'opened',
        searchInputPlaceholder: 'Search Jira issues',
        searchTokens: [],
        sortOptions: AvailableSortOptions,
        initialFilterValue: [
          {
            type: 'filtered-search-term',
            value: {
              data: 'foo',
            },
          },
        ],
        initialSortBy: 'created_desc',
        issuables: [],
        issuablesLoading: true,
        showPaginationControls: wrapper.vm.showPaginationControls,
        defaultPageSize: 2, // mocked value in tests
        totalItems: 0,
        currentPage: 1,
        previousPage: 0,
        nextPage: 2,
        urlParams: wrapper.vm.urlParams,
        recentSearchesStorageKey: 'jira_issues',
        enableLabelPermalinks: false,
      });
    });

    describe('issuable-list events', () => {
      beforeEach(() => {
        jest.spyOn(wrapper.vm, 'fetchIssues');
      });

      it('click-tab event changes currentState value and calls fetchIssues via `fetchIssuesBy`', () => {
        getIssuableList().vm.$emit('click-tab', 'closed');

        expect(wrapper.vm.currentState).toBe('closed');
        expect(wrapper.vm.fetchIssues).toHaveBeenCalled();
      });

      it('page-change event changes currentPage value and calls fetchIssues via `fetchIssuesBy`', () => {
        getIssuableList().vm.$emit('page-change', 2);

        expect(wrapper.vm.currentPage).toBe(2);
        expect(wrapper.vm.fetchIssues).toHaveBeenCalled();
      });

      it('sort event changes sortedBy value and calls fetchIssues via `fetchIssuesBy`', () => {
        getIssuableList().vm.$emit('sort', 'updated_asc');

        expect(wrapper.vm.sortedBy).toBe('updated_asc');
        expect(wrapper.vm.fetchIssues).toHaveBeenCalled();
      });

      it('filter event sets `filterParams` value and calls fetchIssues', () => {
        getIssuableList().vm.$emit('filter', [
          {
            type: 'filtered-search-term',
            value: {
              data: 'foo',
            },
          },
        ]);

        expect(wrapper.vm.filterParams).toEqual({
          search: 'foo',
        });
        expect(wrapper.vm.fetchIssues).toHaveBeenCalled();
      });
    });
  });
});
