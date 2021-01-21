import { shallowMount } from '@vue/test-utils';

import TestCaseListRoot from 'ee/test_case_list/components/test_case_list_root.vue';
import { TestCaseTabs, AvailableSortOptions } from 'ee/test_case_list/constants';
import { TEST_HOST } from 'helpers/test_constants';
import { mockIssuable } from 'jest/issuable_list/mock_data';

import IssuableList from '~/issuable_list/components/issuable_list_root.vue';

jest.mock('~/flash');
jest.mock('ee/test_case_list/constants', () => ({
  DEFAULT_PAGE_SIZE: 2,
  TestCaseTabs: jest.requireActual('ee/test_case_list/constants').TestCaseTabs,
  AvailableSortOptions: jest.requireActual('ee/test_case_list/constants').AvailableSortOptions,
}));

const mockProvide = {
  canCreateTestCase: true,
  initialState: 'opened',
  page: 1,
  prev: '',
  next: '',
  initialSortBy: 'created_desc',
  projectFullPath: 'gitlab-org/gitlab-test',
  projectLabelsPath: '/gitlab-org/gitlab-test/-/labels.json',
  testCaseNewPath: '/gitlab-org/gitlab-test/-/quality/test_cases/new',
};

const mockPageInfo = {
  startCursor: 'eyJpZCI6IjI1IiwiY3JlYXRlZF9hdCI6IjIwMjAtMDMtMzEgMTM6MzI6MTQgVVRDIn0',
  endCursor: 'eyJpZCI6IjIxIiwiY3JlYXRlZF9hdCI6IjIwMjAtMDMtMzEgMTM6MzE6MTUgVVRDIn0',
};

const createComponent = ({
  provide = mockProvide,
  initialFilterParams = {},
  testCasesLoading = false,
  testCasesList = [],
} = {}) =>
  shallowMount(TestCaseListRoot, {
    propsData: {
      initialFilterParams,
    },
    provide,
    mocks: {
      $apollo: {
        queries: {
          testCases: {
            loading: testCasesLoading,
            list: testCasesList,
            pageInfo: mockPageInfo,
          },
          testCasesCount: {
            loading: testCasesLoading,
            opened: 5,
            closed: 0,
            all: 5,
          },
        },
      },
    },
  });

describe('TestCaseListRoot', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('computed', () => {
    describe('testCaseListLoading', () => {
      it.each`
        testCasesLoading | returnValue
        ${true}          | ${true}
        ${false}         | ${false}
      `(
        'returns $returnValue when testCases query loading is $loadingValue',
        ({ testCasesLoading, returnValue }) => {
          const wrapperTemp = createComponent({
            provide: mockProvide,
            initialFilterParams: {},
            testCasesList: [],
            testCasesLoading,
          });

          expect(wrapperTemp.vm.testCaseListLoading).toBe(returnValue);

          wrapperTemp.destroy();
        },
      );
    });

    describe('testCaseListEmpty', () => {
      it.each`
        testCasesLoading | testCasesList     | testCaseListDescription | returnValue
        ${true}          | ${[]}             | ${'empty'}              | ${false}
        ${true}          | ${[mockIssuable]} | ${'not empty'}          | ${false}
        ${false}         | ${[]}             | ${'not empty'}          | ${true}
        ${false}         | ${[mockIssuable]} | ${'empty'}              | ${true}
      `(
        'returns $returnValue when testCases query loading is $testCasesLoading and testCases array is $testCaseListDescription',
        ({ testCasesLoading, testCasesList, returnValue }) => {
          const wrapperTemp = createComponent({
            provide: mockProvide,
            initialFilterParams: {},
            testCasesLoading,
            testCasesList,
          });

          expect(wrapperTemp.vm.testCaseListEmpty).toBe(returnValue);

          wrapperTemp.destroy();
        },
      );
    });

    describe('showPaginationControls', () => {
      it.each`
        hasPreviousPage | hasNextPage  | returnValue
        ${true}         | ${undefined} | ${true}
        ${undefined}    | ${true}      | ${true}
        ${false}        | ${undefined} | ${false}
        ${undefined}    | ${false}     | ${false}
        ${false}        | ${false}     | ${false}
        ${true}         | ${true}      | ${true}
      `(
        'returns $returnValue when hasPreviousPage is $hasPreviousPage and hasNextPage is $hasNextPage within `testCases.pageInfo`',
        async ({ hasPreviousPage, hasNextPage, returnValue }) => {
          wrapper.setData({
            testCases: {
              pageInfo: {
                hasPreviousPage,
                hasNextPage,
              },
            },
          });

          await wrapper.vm.$nextTick();

          expect(wrapper.vm.showPaginationControls).toBe(returnValue);
        },
      );

      it.each`
        testCasesList     | testCaseListDescription | returnValue
        ${[]}             | ${'empty'}              | ${false}
        ${[mockIssuable]} | ${'not empty'}          | ${true}
      `(
        'returns $returnValue when testCases array is $testCaseListDescription',
        async ({ testCasesList, returnValue }) => {
          wrapper.setData({
            testCases: {
              list: testCasesList,
            },
          });

          await wrapper.vm.$nextTick();

          expect(wrapper.vm.showPaginationControls).toBe(returnValue);
        },
      );
    });

    describe('previousPage', () => {
      it('returns number representing previous page based on currentPage value', () => {
        wrapper.setData({
          currentPage: 3,
        });

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.previousPage).toBe(2);
        });
      });
    });

    describe('nextPage', () => {
      beforeEach(() => {
        wrapper.setData({
          testCasesCount: {
            opened: 5,
            closed: 0,
            all: 5,
          },
        });
      });

      it('returns number representing next page based on currentPage value', async () => {
        wrapper.setData({
          currentPage: 1,
        });

        await wrapper.vm.$nextTick();

        expect(wrapper.vm.nextPage).toBe(2);
      });

      it('returns `null` when currentPage is already last page', async () => {
        wrapper.setData({
          currentPage: 3,
        });

        await wrapper.vm.$nextTick();

        expect(wrapper.vm.nextPage).toBeNull();
      });
    });
  });

  describe('methods', () => {
    describe('updateUrl', () => {
      it('updates window URL based on presence of props for filtered search and sort criteria', async () => {
        wrapper.setData({
          currentState: 'opened',
          currentPage: 2,
          nextPageCursor: 'abc123',
          sortedBy: 'updated_asc',
          filterParams: {
            authorUsernames: 'root',
            search: 'foo',
            labelName: ['bug'],
          },
        });

        await wrapper.vm.$nextTick();

        wrapper.vm.updateUrl();

        expect(global.window.location.href).toBe(
          `${TEST_HOST}/?state=opened&sort=updated_asc&page=2&next=abc123&label_name%5B%5D=bug&search=foo`,
        );
      });
    });
  });

  describe('template', () => {
    const getIssuableList = () => wrapper.find(IssuableList);

    it('renders issuable-list component', () => {
      expect(getIssuableList().exists()).toBe(true);
      expect(getIssuableList().props()).toMatchObject({
        namespace: mockProvide.projectFullPath,
        tabs: TestCaseTabs,
        tabCounts: {
          opened: 0,
          closed: 0,
          all: 0,
        },
        currentTab: 'opened',
        searchInputPlaceholder: 'Search test cases',
        searchTokens: expect.any(Array),
        sortOptions: AvailableSortOptions,
        initialSortBy: 'created_desc',
        issuables: [],
        issuablesLoading: false,
        showPaginationControls: wrapper.vm.showPaginationControls,
        defaultPageSize: 2, // mocked value in tests
        currentPage: 1,
        previousPage: 0,
        nextPage: null,
        recentSearchesStorageKey: 'test_cases',
        issuableSymbol: '#',
      });
    });

    describe('issuable-list events', () => {
      beforeEach(() => {
        jest.spyOn(wrapper.vm, 'updateUrl').mockImplementation(jest.fn);
      });

      it('click-tab event changes currentState value and calls updateUrl', () => {
        getIssuableList().vm.$emit('click-tab', 'closed');

        expect(wrapper.vm.currentState).toBe('closed');
        expect(wrapper.vm.updateUrl).toHaveBeenCalled();
      });

      it('page-change event changes prevPageCursor and nextPageCursor values based on based on currentPage and calls updateUrl', () => {
        wrapper.setData({
          testCases: {
            pageInfo: mockPageInfo,
          },
        });

        getIssuableList().vm.$emit('page-change', 2);

        expect(wrapper.vm.prevPageCursor).toBe('');
        expect(wrapper.vm.nextPageCursor).toBe(mockPageInfo.endCursor);
        expect(wrapper.vm.updateUrl).toHaveBeenCalled();
      });

      it('filter event changes filterParams value and calls updateUrl', () => {
        getIssuableList().vm.$emit('filter', [
          {
            type: 'author_username',
            value: {
              data: 'root',
            },
          },
          {
            type: 'label_name',
            value: {
              data: 'bug',
            },
          },
          {
            type: 'filtered-search-term',
            value: {
              data: 'foo',
            },
          },
        ]);

        expect(wrapper.vm.filterParams).toEqual({
          authorUsername: 'root',
          labelName: ['bug'],
          search: 'foo',
        });
        expect(wrapper.vm.updateUrl).toHaveBeenCalled();
      });

      it('sort event changes sortedBy value and calls updateUrl', () => {
        getIssuableList().vm.$emit('sort', 'updated_desc');

        expect(wrapper.vm.sortedBy).toEqual('updated_desc');
        expect(wrapper.vm.updateUrl).toHaveBeenCalled();
      });
    });
  });
});
