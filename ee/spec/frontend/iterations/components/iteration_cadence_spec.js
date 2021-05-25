import { GlInfiniteScroll, GlSkeletonLoader } from '@gitlab/ui';
import { createLocalVue, RouterLinkStub } from '@vue/test-utils';
import { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import IterationCadence from 'ee/iterations/components/iteration_cadence.vue';
import iterationsInCadenceQuery from 'ee/iterations/queries/iterations_in_cadence.query.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import { mountExtended as mount } from 'helpers/vue_test_utils_helper';
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

describe('Iteration cadence list item', () => {
  let wrapper;
  let apolloProvider;

  const groupPath = 'gitlab-org';
  const iterations = [
    {
      dueDate: '2021-08-14',
      id: 'gid://gitlab/Iteration/41',
      scopedPath: '/groups/group1/-/iterations/41',
      startDate: '2021-08-13',
      state: 'upcoming',
      title: 'My title 44',
      webPath: '/groups/group1/-/iterations/41',
      __typename: 'Iteration',
    },
  ];

  const cadence = {
    id: 'gid://gitlab/Iterations::Cadence/561',
    title: 'Weekly cadence',
    durationInWeeks: 3,
  };

  const startCursor = 'MQ';
  const endCursor = 'MjA';
  const querySuccessResponse = {
    data: {
      group: {
        iterations: {
          nodes: iterations,
          pageInfo: {
            hasNextPage: true,
            hasPreviousPage: false,
            startCursor,
            endCursor,
          },
        },
      },
    },
  };

  const queryEmptyResponse = {
    data: {
      group: {
        iterations: {
          nodes: [],
          pageInfo: {
            hasNextPage: false,
            hasPreviousPage: false,
            startCursor: null,
            endCursor: null,
          },
        },
      },
    },
  };

  function createComponent({
    props = {},
    canCreateCadence,
    resolverMock = jest.fn().mockResolvedValue(querySuccessResponse),
  } = {}) {
    apolloProvider = createMockApolloProvider([[iterationsInCadenceQuery, resolverMock]]);

    wrapper = mount(IterationCadence, {
      localVue,
      apolloProvider,
      mocks: {
        $router,
      },
      stubs: {
        RouterLink: RouterLinkStub,
      },
      provide: {
        groupPath,
        canCreateCadence,
      },
      propsData: {
        title: cadence.title,
        cadenceId: cadence.id,
        ...props,
      },
    });

    return nextTick();
  }

  const findLoader = () => wrapper.findComponent(GlSkeletonLoader);
  const expand = () => wrapper.findByRole('button', { text: cadence.title }).trigger('click');

  afterEach(() => {
    wrapper.destroy();
    apolloProvider = null;
  });

  it('does not query iterations when component mounted', async () => {
    const resolverMock = jest.fn();

    await createComponent({
      resolverMock,
    });

    expect(resolverMock).not.toHaveBeenCalled();
  });

  it('shows empty text when no results', async () => {
    await createComponent({
      resolverMock: jest.fn().mockResolvedValue(queryEmptyResponse),
    });

    expand();

    await waitForPromises();

    expect(findLoader().exists()).toBe(false);
    expect(wrapper.text()).toContain(wrapper.vm.i18n.noResults);
  });

  it('shows iterations after loading', async () => {
    await createComponent();

    expand();

    await waitForPromises();

    iterations.forEach(({ title }) => {
      expect(wrapper.text()).toContain(title);
    });
  });

  it('shows alert on query error', async () => {
    await createComponent({
      resolverMock: jest.fn().mockRejectedValue(queryEmptyResponse),
    });

    await expand();

    await waitForPromises();

    expect(findLoader().exists()).toBe(false);
    expect(wrapper.text()).toContain(wrapper.vm.i18n.error);
  });

  it('calls fetchMore after scrolling down', async () => {
    await createComponent();

    jest.spyOn(wrapper.vm.$apollo.queries.group, 'fetchMore').mockResolvedValue({});

    expand();

    await waitForPromises();

    wrapper.findComponent(GlInfiniteScroll).vm.$emit('bottomReached');

    expect(wrapper.vm.$apollo.queries.group.fetchMore).toHaveBeenCalledWith(
      expect.objectContaining({
        variables: expect.objectContaining({
          afterCursor: endCursor,
        }),
      }),
    );
  });
});
