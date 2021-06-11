import { shallowMount, createLocalVue } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import VueApollo from 'vue-apollo';

import JiraIssuesListRoot from 'ee/integrations/jira/issues_list/components/jira_issues_list_root.vue';
import jiraIssues from 'ee/integrations/jira/issues_list/graphql/resolvers/jira_issues';

import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';

import createFlash from '~/flash';
import IssuableList from '~/issuable_list/components/issuable_list_root.vue';
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

const localVue = createLocalVue();

const resolvers = {
  Query: {
    jiraIssues,
  },
};

function createMockApolloProvider() {
  localVue.use(VueApollo);
  return createMockApollo([], resolvers);
}

describe('JiraIssuesListRoot', () => {
  let wrapper;
  let mock;

  const findIssuableList = () => wrapper.find(IssuableList);

  const createComponent = ({ provide = mockProvide, initialFilterParams = {} } = {}) => {
    wrapper = shallowMount(JiraIssuesListRoot, {
      propsData: {
        initialFilterParams,
      },
      provide,
      localVue,
      apolloProvider: createMockApolloProvider(),
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  describe('on mount', () => {
    describe('while loading', () => {
      it('sets issuesListLoading to `true`', async () => {
        jest.spyOn(axios, 'get').mockResolvedValue(new Promise(() => {}));

        createComponent();

        await wrapper.vm.$nextTick();

        const issuableList = findIssuableList();
        expect(issuableList.props('issuablesLoading')).toBe(true);
      });

      it('calls `axios.get` with `issuesFetchPath` and query params', async () => {
        jest.spyOn(axios, 'get');
        createComponent();

        await waitForPromises();

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
        const issuableList = findIssuableList();
        const issuablesProp = issuableList.props('issuables');

        expect(issuableList.props()).toMatchObject({
          currentPage: resolvedValue.headers['x-page'],
          previousPage: resolvedValue.headers['x-page'] - 1,
          nextPage: resolvedValue.headers['x-page'] + 1,
          totalItems: resolvedValue.headers['x-total'],
        });

        expect(issuablesProp).toMatchObject(
          convertObjectPropsToCamelCase(mockJiraIssues, { deep: true }),
        );
      });

      it('sets issuesListLoading to `false`', () => {
        const issuableList = findIssuableList();
        expect(issuableList.props('issuablesLoading')).toBe(false);
      });
    });

    describe('when request fails', () => {
      it.each`
        APIErrors        | expectedRenderedErrorMessage
        ${['API error']} | ${'API error'}
        ${undefined}     | ${'An error occurred while loading issues'}
      `(
        'calls `createFlash` with "$expectedRenderedErrorMessage" when API responds with "$APIErrors"',
        async ({ APIErrors, expectedRenderedErrorMessage }) => {
          jest.spyOn(axios, 'get');
          mock
            .onGet(mockProvide.issuesFetchPath)
            .replyOnce(httpStatus.INTERNAL_SERVER_ERROR, { errors: APIErrors });

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

  it('renders issuable-list component with correct props', async () => {
    createComponent({ initialFilterParams: { search: 'foo' } });

    await waitForPromises();

    const issuableList = findIssuableList();
    expect(issuableList.exists()).toBe(true);
    expect(issuableList.props()).toMatchSnapshot();
  });

  describe('issuable-list events', () => {
    beforeEach(async () => {
      jest.spyOn(axios, 'get');
      createComponent();
      await waitForPromises();
    });

    it('"click-tab" event executes GET request correctly', async () => {
      const issuableList = findIssuableList();

      issuableList.vm.$emit('click-tab', 'closed');
      await waitForPromises();

      expect(axios.get).toHaveBeenCalledWith(mockProvide.issuesFetchPath, {
        params: {
          labels: undefined,
          page: 1,
          per_page: 2,
          search: undefined,
          sort: 'created_desc',
          state: 'closed',
          with_labels_details: true,
        },
      });
      expect(issuableList.props('currentTab')).toBe('closed');
    });

    it('"page-change" event executes GET request correctly', async () => {
      const mockPage = 2;
      const issuableList = findIssuableList();

      issuableList.vm.$emit('page-change', mockPage);
      await waitForPromises();

      expect(axios.get).toHaveBeenCalledWith(mockProvide.issuesFetchPath, {
        params: {
          labels: undefined,
          page: mockPage,
          per_page: 2,
          search: undefined,
          sort: 'created_desc',
          state: 'opened',
          with_labels_details: true,
        },
      });
      expect(issuableList.props()).toMatchObject({
        currentPage: mockPage,
        previousPage: mockPage - 1,
        nextPage: mockPage + 1,
      });
    });

    it('"sort" event executes GET request correctly', async () => {
      const mockSortBy = 'updated_asc';
      const issuableList = findIssuableList();

      issuableList.vm.$emit('sort', mockSortBy);
      await waitForPromises();

      expect(axios.get).toHaveBeenCalledWith(mockProvide.issuesFetchPath, {
        params: {
          labels: undefined,
          page: 1,
          per_page: 2,
          search: undefined,
          sort: 'created_desc',
          state: 'opened',
          with_labels_details: true,
        },
      });
      expect(issuableList.props('initialSortBy')).toBe(mockSortBy);
    });

    it('filter event sets `filterParams` value and calls fetchIssues', async () => {
      const mockFilterTerm = 'foo';
      const issuableList = findIssuableList();

      issuableList.vm.$emit('filter', [
        {
          type: 'filtered-search-term',
          value: {
            data: mockFilterTerm,
          },
        },
      ]);
      await waitForPromises();

      expect(axios.get).toHaveBeenCalledWith(mockProvide.issuesFetchPath, {
        params: {
          labels: undefined,
          page: 1,
          per_page: 2,
          search: mockFilterTerm,
          sort: 'created_desc',
          state: 'opened',
          with_labels_details: true,
        },
      });
    });
  });

  describe('pagination', () => {
    it.each`
      scenario                 | issuesListLoadFailed | issues            | shouldShowPaginationControls
      ${'fails'}               | ${true}              | ${[]}             | ${false}
      ${'returns no issues'}   | ${false}             | ${[]}             | ${false}
      ${`returns some issues`} | ${false}             | ${mockJiraIssues} | ${true}
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
