import {
  GlAvatar,
  GlAvatarLabeled,
  GlIntersectionObserver,
  GlToken,
  GlTokenSelector,
  GlLoadingIcon,
} from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import produce from 'immer';
import Vue from 'vue';
import VueApollo from 'vue-apollo';

import { getJSONFixture } from 'helpers/fixtures';
import createMockApollo from 'helpers/mock_apollo_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import ProjectsTokenSelector from '~/access_tokens/components/projects_token_selector.vue';
import getProjectsQuery from '~/access_tokens/graphql/queries/get_projects.query.graphql';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

describe('ProjectsTokenSelector', () => {
  const getProjectsQueryResponse = getJSONFixture(
    'graphql/projects/access_tokens/get_projects.query.graphql.json',
  );
  const getProjectsQueryResponsePage2 = produce(
    getProjectsQueryResponse,
    (getProjectsQueryResponseDraft) => {
      /* eslint-disable no-param-reassign */
      getProjectsQueryResponseDraft.data.projects.pageInfo.hasNextPage = false;
      getProjectsQueryResponseDraft.data.projects.pageInfo.endCursor = null;
      getProjectsQueryResponseDraft.data.projects.nodes.splice(1, 1);
      getProjectsQueryResponseDraft.data.projects.nodes[0].id = 'gid://gitlab/Project/100';
      /* eslint-enable no-param-reassign */
    },
  );

  const { pageInfo, nodes: projects } = getProjectsQueryResponse.data.projects;
  const project1 = projects[0];

  let wrapper;

  let resolveGetProjectsQuery;
  const getProjectsQueryRequestHandler = jest.fn(
    () =>
      new Promise((resolve) => {
        resolveGetProjectsQuery = resolve;
      }),
  );

  const createComponent = ({
    propsData = {},
    apolloProvider = createMockApollo([[getProjectsQuery, getProjectsQueryRequestHandler]]),
    resolveQueries = true,
  } = {}) => {
    Vue.use(VueApollo);

    wrapper = extendedWrapper(
      mount(ProjectsTokenSelector, {
        apolloProvider,
        propsData: {
          selectedProjects: [],
          ...propsData,
        },
        stubs: ['gl-intersection-observer'],
      }),
    );

    if (resolveQueries) {
      resolveGetProjectsQuery(getProjectsQueryResponse);

      return waitForPromises();
    }

    return Promise.resolve();
  };

  const findTokenSelector = () => wrapper.findComponent(GlTokenSelector);
  const findTokenSelectorInput = () => findTokenSelector().find('input[type="text"]');

  it('renders dropdown items with project avatars', async () => {
    await createComponent();

    wrapper.findAllComponents(GlAvatarLabeled).wrappers.forEach((avatarLabeledWrapper, index) => {
      const project = projects[index];

      expect(avatarLabeledWrapper.attributes()).toEqual(
        expect.objectContaining({
          'entity-id': `${getIdFromGraphQLId(project.id)}`,
          'entity-name': project.name,
          ...(project.avatarUrl && { src: project.avatarUrl }),
        }),
      );

      expect(avatarLabeledWrapper.props()).toEqual(
        expect.objectContaining({
          label: project.name,
          subLabel: project.nameWithNamespace,
        }),
      );
    });
  });

  it('renders tokens with project avatars', () => {
    createComponent({
      propsData: {
        selectedProjects: [{ ...project1, id: getIdFromGraphQLId(project1.id) }],
      },
    });

    const token = wrapper.findComponent(GlToken);
    const avatar = token.findComponent(GlAvatar);

    expect(token.text()).toContain(project1.nameWithNamespace);
    expect(avatar.attributes('src')).toBe(project1.avatarUrl || undefined);
    expect(avatar.props()).toEqual(
      expect.objectContaining({
        entityId: getIdFromGraphQLId(project1.id),
        entityName: project1.name,
      }),
    );
  });

  describe('when `enter` key is pressed', () => {
    it('calls `preventDefault` so form is not submitted when user selects a project from the dropdown', () => {
      createComponent();

      const event = {
        preventDefault: jest.fn(),
      };

      findTokenSelectorInput().trigger('keydown.enter', event);

      expect(event.preventDefault).toHaveBeenCalled();
    });
  });

  describe('when text input is typed in', () => {
    const searchTerm = 'foo bar';

    beforeEach(async () => {
      await createComponent();

      const tokenSelectorInput = findTokenSelectorInput();
      tokenSelectorInput.element.value = searchTerm;
      tokenSelectorInput.trigger('input');
    });

    it('makes GraphQL request with `search` variable set', async () => {
      expect(getProjectsQueryRequestHandler).toHaveBeenLastCalledWith({
        search: searchTerm,
        after: null,
        first: 20,
      });
    });

    it('sets loading state while waiting for GraphQL request to resolve', async () => {
      expect(findTokenSelector().props('loading')).toBe(true);

      resolveGetProjectsQuery(getProjectsQueryResponse);
      await waitForPromises();

      expect(findTokenSelector().props('loading')).toBe(false);
    });
  });

  describe('when user scrolls to the bottom of the dropdown', () => {
    beforeEach(async () => {
      await createComponent();

      wrapper.findComponent(GlIntersectionObserver).vm.$emit('appear');
    });

    it('makes GraphQL request with `after` variable set', async () => {
      expect(getProjectsQueryRequestHandler).toHaveBeenLastCalledWith({
        after: pageInfo.endCursor,
        first: 20,
        search: '',
      });
    });

    it('displays loading icon while waiting for GraphQL request to resolve', async () => {
      expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(true);

      resolveGetProjectsQuery(getProjectsQueryResponsePage2);
      await waitForPromises();

      expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(false);
    });
  });

  describe('when `GlTokenSelector` emits `input` event', () => {
    it('emits `input` event used by `v-model`', () => {
      findTokenSelector().vm.$emit('input', project1);

      expect(wrapper.emitted('input')[0]).toEqual([project1]);
    });
  });

  describe('when `GlTokenSelector` emits `focus` event', () => {
    it('emits `focus` event', () => {
      const event = { fakeEvent: 'foo' };
      findTokenSelector().vm.$emit('focus', event);

      expect(wrapper.emitted('focus')[0]).toEqual([event]);
    });
  });
});
