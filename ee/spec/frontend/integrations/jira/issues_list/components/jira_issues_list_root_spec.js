import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';

import JiraIssuesListRoot from 'ee/integrations/jira/issues_list/components/jira_issues_list_root.vue';
import waitForPromises from 'helpers/wait_for_promises';

import createFlash from '~/flash';
import IssuableList from '~/issuable_list/components/issuable_list_root.vue';
import { IssuableStates, IssuableListTabs, AvailableSortOptions } from '~/issuable_list/constants';
import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import httpStatus from '~/lib/utils/http_status';

import { mockProvide, mockJiraIssues } from '../mock_data';

jest.mock('~/flash');
jest.mock('~/issuable_list/constants', () => ({
  DEFAULT_PAGE_SIZE: 2,
  IssuableStates: jest.requireActual('~/issuable_list/constants').IssuableStates,
  IssuableListTabs: jest.requireActual('~/issuable_list/constants').IssuableListTabs,
  AvailableSortOptions: jest.requireActual('~/issuable_list/constants').AvailableSortOptions,
}));

const resolvedValue = {
  headers: {
    'x-page': 1,
    'x-total': 3,
  },
  data: mockJiraIssues,
};

describe('JiraIssuesListRoot', () => {
  let wrapper;
  let mock;

  const findIssuableList = () => wrapper.find(IssuableList);

  const createComponent = ({ provide = mockProvide, initialFilterParams = {}, data = {} } = {}) => {
    wrapper = shallowMount(JiraIssuesListRoot, {
      propsData: {
        initialFilterParams,
      },
      provide,
      data() {
        return data;
      },
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  describe('computed', () => {
    describe('urlParams', () => {
      it('returns object containing `state`, `page`, `sort` and `search` properties', () => {
        createComponent({
          data: {
            currentState: 'closed',
            currentPage: 2,
            sortedBy: 'created_asc',
            filterParams: {
              search: 'foo',
            },
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
    describe('fetchIssuesBy', () => {
      it('sets provided prop value for given prop name and calls `fetchIssues`', () => {
        jest.spyOn(axios, 'get');
        createComponent();

        wrapper.vm.fetchIssuesBy('currentPage', 2);

        expect(wrapper.vm.currentPage).toBe(2);
        expect(axios.get).toHaveBeenCalled();
      });
    });
  });

  describe('template', () => {
    it('renders issuable-list component', async () => {
      createComponent({
        data: {
          filterParams: {
            search: 'foo',
          },
        },
      });

      await waitForPromises();

      const issuableList = findIssuableList();
      expect(issuableList.exists()).toBe(true);
      expect(issuableList.props()).toMatchObject({
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
        issuablesLoading: false,
        showPaginationControls: wrapper.vm.showPaginationControls,
        defaultPageSize: 2, // mocked value in tests
        totalItems: 0,
        currentPage: 1,
        previousPage: 0,
        nextPage: 2,
        urlParams: wrapper.vm.urlParams,
        recentSearchesStorageKey: 'jira_issues',
        enableLabelPermalinks: true,
      });
    });

    describe('issuable-list events', () => {
      beforeEach(async () => {
        jest.spyOn(axios, 'get');
        createComponent();
        await waitForPromises();
      });

      it('click-tab event changes currentState value and calls fetchIssues via `fetchIssuesBy`', () => {
        findIssuableList().vm.$emit('click-tab', 'closed');

        expect(wrapper.vm.currentState).toBe('closed');
        expect(axios.get).toHaveBeenCalled();
      });

      it('page-change event changes currentPage value and calls fetchIssues via `fetchIssuesBy`', () => {
        findIssuableList().vm.$emit('page-change', 2);

        expect(wrapper.vm.currentPage).toBe(2);
        expect(axios.get).toHaveBeenCalled();
      });

      it('sort event changes sortedBy value and calls fetchIssues via `fetchIssuesBy`', () => {
        findIssuableList().vm.$emit('sort', 'updated_asc');

        expect(wrapper.vm.sortedBy).toBe('updated_asc');
        expect(axios.get).toHaveBeenCalled();
      });

      it('filter event sets `filterParams` value and calls fetchIssues', () => {
        findIssuableList().vm.$emit('filter', [
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
        expect(axios.get).toHaveBeenCalled();
      });
    });

    describe('pagination', () => {
      it.each`
        scenario               | issuesListLoadFailed | issues            | shouldShowPaginationControls
        ${'fails'}             | ${true}              | ${[]}             | ${false}
        ${'returns no issues'} | ${false}             | ${[]}             | ${false}
        ${`returns issues`}    | ${false}             | ${mockJiraIssues} | ${true}
      `(
        'sets `showPaginationControls` prop to $shouldShowPaginationControls when request $scenario',
        async ({ issuesListLoadFailed, issues, shouldShowPaginationControls }) => {
          jest.spyOn(axios, 'get');
          mock
            .onGet(mockProvide.issuesFetchPath)
            .replyOnce(
              issuesListLoadFailed ? httpStatus.INTERNAL_SERVER_ERROR : httpStatus.OK,
              issues,
              {
                'x-page': 1,
                'x-total': 3,
              },
            );

          createComponent();

          await waitForPromises();

          expect(findIssuableList().props('showPaginationControls')).toBe(
            shouldShowPaginationControls,
          );
        },
      );
    });
  });

  describe('on mount', () => {
    describe('while loading', () => {
      it('sets issuesListLoading to `true`', () => {
        jest.spyOn(axios, 'get').mockResolvedValue(new Promise(() => {}));

        createComponent();

        const issuableList = findIssuableList();
        expect(issuableList.props('issuablesLoading')).toBe(true);
      });

      it('calls `axios.get` with `issuesFetchPath` and query params', () => {
        jest.spyOn(axios, 'get');
        createComponent();

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
    });

    describe('when request succeeds', () => {
      beforeEach(async () => {
        jest.spyOn(axios, 'get').mockResolvedValue(resolvedValue);

        createComponent();
        await waitForPromises();
      });

      it('sets `currentPage` and `totalIssues` from response headers and `issues` & `issuesCount` from response body when request is successful', async () => {
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

      it('sets issuesListLoading to `false`', () => {
        const issuableList = findIssuableList();
        expect(issuableList.props('issuablesLoading')).toBe(false);
      });
    });

    describe('when request fails', () => {
      it.each`
        APIErrorMessage | expectedRenderedErrorMessage
        ${'API error'}  | ${'An error occurred while loading issues'}
        ${undefined}    | ${'An error occurred while loading issues'}
      `(
        'calls `createFlash` with "$expectedRenderedErrorMessage" when API responds with "$APIErrorMessage"',
        async ({ APIErrorMessage, expectedRenderedErrorMessage }) => {
          jest.spyOn(axios, 'get');
          mock
            .onGet(mockProvide.issuesFetchPath)
            .replyOnce(httpStatus.INTERNAL_SERVER_ERROR, { errors: [APIErrorMessage] });

          createComponent();

          await waitForPromises();

          expect(createFlash).toHaveBeenCalledWith({
            message: expectedRenderedErrorMessage,
            captureError: true,
            error: expect.any(Object),
          });
        },
      );
    });
  });
});
