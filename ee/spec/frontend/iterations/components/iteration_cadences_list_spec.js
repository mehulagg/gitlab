import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import { mount, createLocalVue } from '@vue/test-utils';
import { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import IterationCadencesList from 'ee/iterations/components/iteration_cadences_list.vue';
import cadencesListQuery from 'ee/iterations/queries/iteration_cadences_list.query.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import { TEST_HOST } from 'helpers/test_constants';
import waitForPromises from 'helpers/wait_for_promises';

const push = jest.fn();
const $router = {
  push,
};

const localVue = createLocalVue();

function createMockApolloProvider(requestHandlers) {
  localVue.use(VueApollo);

  return createMockApollo(requestHandlers);
}

describe('Iteration cadences list', () => {
  let wrapper;
  let apolloProvider;

  const groupPath = 'gitlab-org';
  const cadences = [
    {
      id: 'gid://gitlab/Iterations::Cadence/561',
      title: 'A eligendi molestias temporibus maiores architecto ut facilis autem.',
      durationInWeeks: 3,
    },
    {
      id: 'gid://gitlab/Iterations::Cadence/392',
      title: 'A quam repellat omnis eum veritatis voluptas voluptatem consequuntur est.',
      durationInWeeks: 4,
    },
    {
      id: 'gid://gitlab/Iterations::Cadence/152',
      title: 'A repudiandae ut eligendi quae et ducimus porro nam sint perferendis.',
      durationInWeeks: 1,
    },
  ];

  const querySuccessResponse = {
    data: {
      group: {
        iterationCadences: {
          nodes: cadences,
          pageInfo: {
            hasNextPage: true,
            hasPreviousPage: false,
            startCursor: 'MQ',
            endCursor: 'MjA',
          },
        },
      },
    },
  };

  const queryEmptyResponse = {
    data: {
      group: {
        iterationCadences: {
          nodes: [],
          pageInfo: {
            hasNextPage: false,
            hasPreviousPage: false,
            startCursor: 'MQ',
            endCursor: 'MjA',
          },
        },
      },
    },
  };

  function createComponent({
    canCreateCadence,
    resolverMock = jest.fn().mockResolvedValue(querySuccessResponse),
  } = {}) {
    apolloProvider = createMockApolloProvider([[cadencesListQuery, resolverMock]]);

    wrapper = mount(IterationCadencesList, {
      localVue,
      apolloProvider,
      mocks: {
        $router,
      },
      provide: {
        groupPath,
        cadencesListPath: TEST_HOST,
        canCreateCadence,
      },
    });

    return nextTick();
  }

  const withText = (text) => (node) => node.text().match(text);
  const createCadenceButtons = () =>
    wrapper.findAllComponents(GlButton).filter(withText('New iteration cadence'));
  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);

  afterEach(() => {
    wrapper.destroy();
    apolloProvider = null;
  });

  describe('Create cadence button', () => {
    it('is shown when canCreateCadence is true', async () => {
      await createComponent({ canCreateCadence: true });

      expect(createCadenceButtons()).toHaveLength(1);
    });

    it('is hidden when canCreateCadence is false', async () => {
      await createComponent({
        canCreateCadence: false,
      });

      expect(createCadenceButtons()).toHaveLength(0);
    });
  });

  describe('cadences list', () => {
    it('shows loading state on mount', () => {
      createComponent();

      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('shows empty text when no results', async () => {
      await createComponent({
        resolverMock: jest.fn().mockResolvedValue(queryEmptyResponse),
      });

      await waitForPromises();

      expect(findLoadingIcon().exists()).toBe(false);
      expect(wrapper.text()).toContain('No iteration cadences to show');
    });

    it('shows cadences after loading', async () => {
      await createComponent();

      await waitForPromises();

      cadences.forEach(({ title }) => {
        expect(wrapper.text()).toContain(title);
      });
    });

    it('shows alert on query error', async () => {
      await createComponent({
        resolverMock: jest.fn().mockRejectedValue(queryEmptyResponse),
      });

      await waitForPromises();

      expect(findLoadingIcon().exists()).toBe(false);
      expect(wrapper.text()).toContain('Network error');
    });
  });
});
