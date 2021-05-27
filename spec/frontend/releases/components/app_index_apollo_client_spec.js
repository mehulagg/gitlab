import { cloneDeep } from 'lodash';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createFlash from '~/flash';
import ReleasesIndexApolloClientApp from '~/releases/components/app_index_apollo_client.vue';
import ReleaseBlock from '~/releases/components/release_block.vue';
import ReleaseSkeletonLoader from '~/releases/components/release_skeleton_loader.vue';
import ReleasesEmptyState from '~/releases/components/releases_empty_state.vue';
import ReleasesPaginationApolloClient from '~/releases/components/releases_pagination_apollo_client.vue';
import ReleasesSortApolloClient from '~/releases/components/releases_sort_apollo_client.vue';
import { PAGE_SIZE, RELEASED_AT_DESC, CREATED_ASC } from '~/releases/constants';
import allReleasesQuery from '~/releases/graphql/queries/all_releases.query.graphql';

Vue.use(VueApollo);

jest.mock('~/flash');

let mockQueryParams;
jest.mock('~/lib/utils/common_utils', () => ({
  ...jest.requireActual('~/lib/utils/common_utils'),
  getParameterByName: jest
    .fn()
    .mockImplementation((parameterName) => mockQueryParams[parameterName]),
}));

describe('app_index_apollo_client.vue', () => {
  const originalAllReleasesQueryResponse = getJSONFixture(
    'graphql/releases/graphql/queries/all_releases.query.graphql.json',
  );
  const projectPath = 'project/path';
  const newReleasePath = 'path/to/new/release/page';
  const before = 'beforeCursor';
  const after = 'afterCursor';

  let wrapper;
  let allReleasesQueryResponse;
  let allReleasesQueryMock;

  const createComponent = (queryResponse = Promise.resolve(allReleasesQueryResponse)) => {
    const apolloProvider = createMockApollo([
      [allReleasesQuery, allReleasesQueryMock.mockReturnValueOnce(queryResponse)],
    ]);

    wrapper = shallowMountExtended(ReleasesIndexApolloClientApp, {
      apolloProvider,
      provide: {
        newReleasePath,
        projectPath,
      },
    });
  };

  beforeEach(() => {
    mockQueryParams = {};
    allReleasesQueryResponse = cloneDeep(originalAllReleasesQueryResponse);
    allReleasesQueryMock = jest.fn();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  // Finders
  const findLoadingIndicator = () => wrapper.findComponent(ReleaseSkeletonLoader);
  const findEmptyState = () => wrapper.findComponent(ReleasesEmptyState);
  const findNewReleaseButton = () =>
    wrapper.findByText(ReleasesIndexApolloClientApp.i18n.newRelease);
  const findAllReleaseBlocks = () => wrapper.findAllComponents(ReleaseBlock);
  const findPagination = () => wrapper.findComponent(ReleasesPaginationApolloClient);
  const findSort = () => wrapper.findComponent(ReleasesSortApolloClient);

  // Expectations
  const expectLoadingIndicator = () => {
    it('renders a loading indicator', () => {
      expect(findLoadingIndicator().exists()).toBe(true);
    });
  };

  const expectNoLoadingIndicator = () => {
    it('does not render a loading indicator', () => {
      expect(findLoadingIndicator().exists()).toBe(false);
    });
  };

  const expectEmptyState = () => {
    it('renders the empty state', () => {
      expect(findEmptyState().exists()).toBe(true);
    });
  };

  const expectNoEmptyState = () => {
    it('does not render the empty state', () => {
      expect(findEmptyState().exists()).toBe(false);
    });
  };

  const expectFlashMessage = (message = ReleasesIndexApolloClientApp.i18n.errorMessage) => {
    it(`shows a flash message that reads "${message}"`, () => {
      expect(createFlash).toHaveBeenCalledTimes(1);
      expect(createFlash).toHaveBeenCalledWith({
        message,
        captureError: true,
        error: expect.any(Error),
      });
    });
  };

  const expectNewReleaseButton = () => {
    it('renders the "New Release" button', () => {
      expect(findNewReleaseButton().exists()).toBe(true);
    });
  };

  const expectNoFlashMessage = () => {
    it(`does not show a flash message`, () => {
      expect(createFlash).not.toHaveBeenCalled();
    });
  };

  const expectReleases = (count) => {
    it(`renders ${count} release(s)`, () => {
      expect(findAllReleaseBlocks()).toHaveLength(count);
    });
  };

  const expectPagination = () => {
    it('renders the pagination buttons', () => {
      expect(findPagination().exists()).toBe(true);
    });
  };

  const expectNoPagination = () => {
    it('does not render the pagination buttons', () => {
      expect(findPagination().exists()).toBe(false);
    });
  };

  const expectSort = () => {
    it('renders the sort controls', () => {
      expect(findSort().exists()).toBe(true);
    });
  };

  // Tests
  describe('when the component is loading data', () => {
    beforeEach(() => {
      createComponent(new Promise(() => {}));
    });

    expectLoadingIndicator();
    expectNoEmptyState();
    expectNoFlashMessage();
    expectNewReleaseButton();
    expectReleases(0);
    expectNoPagination();
    expectSort();
  });

  describe('when the data has successfully loaded, but there are no releases', () => {
    beforeEach(() => {
      allReleasesQueryResponse.data.project.releases.nodes = [];
      createComponent(Promise.resolve(allReleasesQueryResponse));
    });

    expectNoLoadingIndicator();
    expectEmptyState();
    expectNoFlashMessage();
    expectNewReleaseButton();
    expectReleases(0);
    expectPagination();
    expectSort();
  });

  describe('when an error occurs while loading data', () => {
    beforeEach(() => {
      createComponent(Promise.reject(new Error('Oops!')));
    });

    expectNoLoadingIndicator();
    expectNoEmptyState();
    expectFlashMessage();
    expectNewReleaseButton();
    expectReleases(0);
    expectNoPagination();
    expectSort();
  });

  describe('when the data has successfully loaded', () => {
    beforeEach(() => {
      createComponent();
    });

    expectNoLoadingIndicator();
    expectNoEmptyState();
    expectNoFlashMessage();
    expectNewReleaseButton();
    expectReleases(originalAllReleasesQueryResponse.data.project.releases.nodes.length);
    expectPagination();
    expectSort();
  });

  describe('URL parameters', () => {
    describe('when the URL contains no query parameters', () => {
      beforeEach(() => {
        createComponent();
      });

      it('makes a request with the correct GraphQL query parameters', () => {
        expect(allReleasesQueryMock).toHaveBeenCalledWith({
          first: PAGE_SIZE,
          fullPath: projectPath,
          sort: RELEASED_AT_DESC,
        });
      });
    });

    describe('when the URL contains a "before" query parameter', () => {
      beforeEach(() => {
        mockQueryParams = { before };
        createComponent();
      });

      it('makes a request with the correct GraphQL query parameters', () => {
        expect(allReleasesQueryMock).toHaveBeenCalledWith({
          before,
          last: PAGE_SIZE,
          fullPath: projectPath,
          sort: RELEASED_AT_DESC,
        });
      });
    });

    describe('when the URL contains an "after" query parameter', () => {
      beforeEach(() => {
        mockQueryParams = { after };
        createComponent();
      });

      it('makes a request with the correct GraphQL query parameters', () => {
        expect(allReleasesQueryMock).toHaveBeenCalledWith({
          after,
          first: PAGE_SIZE,
          fullPath: projectPath,
          sort: RELEASED_AT_DESC,
        });
      });
    });

    describe('when the URL contains both "before" and "after" query parameters', () => {
      beforeEach(() => {
        mockQueryParams = { before, after };
        createComponent();
      });

      it('ignores the "before" parameter and behaves as if only the "after" parameter was provided', () => {
        expect(allReleasesQueryMock).toHaveBeenCalledWith({
          after,
          first: PAGE_SIZE,
          fullPath: projectPath,
          sort: RELEASED_AT_DESC,
        });
      });
    });
  });

  describe('New release button', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the new release button with the correct href', () => {
      expect(findNewReleaseButton().attributes().href).toBe(newReleasePath);
    });
  });

  describe('pagination', () => {
    it('requeries the GraphQL endpoint when a pagination button is clicked', async () => {
      mockQueryParams = { before };

      createComponent();

      await wrapper.vm.$nextTick();

      expect(allReleasesQueryMock.mock.calls).toEqual([[expect.objectContaining({ before })]]);

      mockQueryParams = { after };

      findPagination().vm.$emit('next', after);

      await wrapper.vm.$nextTick();

      expect(allReleasesQueryMock.mock.calls).toEqual([
        [expect.objectContaining({ before })],
        [expect.objectContaining({ after })],
      ]);
    });
  });

  describe('sorting', () => {
    beforeEach(() => {
      createComponent();
    });

    it(`sorts by ${RELEASED_AT_DESC} by default`, () => {
      expect(allReleasesQueryMock.mock.calls).toEqual([
        [expect.objectContaining({ sort: RELEASED_AT_DESC })],
      ]);
    });

    it('requeries the GraphQL endpoint when the sort is changed', async () => {
      findSort().vm.$emit('input', CREATED_ASC);

      await wrapper.vm.$nextTick();

      expect(allReleasesQueryMock.mock.calls).toEqual([
        [expect.objectContaining({ sort: RELEASED_AT_DESC })],
        [expect.objectContaining({ sort: CREATED_ASC })],
      ]);
    });
  });
});
