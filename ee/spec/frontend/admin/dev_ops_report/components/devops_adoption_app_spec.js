import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import MockAdapter from 'axios-mock-adapter';
import VueApollo from 'vue-apollo';
import { createMockClient } from 'mock-apollo-client';
import { resolvers as devOpsResolvers } from 'ee/admin/dev_ops_report/graphql';
import getGroupsQuery from 'ee/admin/dev_ops_report/graphql/queries/get_groups.query.graphql';
import DevopsAdoptionApp from 'ee/admin/dev_ops_report/components/devops_adoption_app.vue';
import DevopsAdoptionEmptyState from 'ee/admin/dev_ops_report/components/devops_adoption_empty_state.vue';
import { DEVOPS_ADOPTION_STRINGS } from 'ee/admin/dev_ops_report/constants';
import axios from '~/lib/utils/axios_utils';
import * as Sentry from '~/sentry/wrapper';
import { groupNodes, groupPageInfo } from '../mock_data';

const localVue = createLocalVue();

describe('DevopsAdoptionApp', () => {
  let wrapper;
  let mockAdapter;

  const createComponent = (options = {}) => {
    const { data = {} } = options;

    const mockClient = createMockClient({
      resolvers: devOpsResolvers,
    });

    mockClient.cache.writeQuery({
      query: getGroupsQuery,
      data,
    });

    const apolloProvider = new VueApollo({
      defaultClient: mockClient,
    });

    return shallowMount(DevopsAdoptionApp, {
      localVue,
      apolloProvider,
    });
  };

  beforeEach(() => {
    mockAdapter = new MockAdapter(axios);
  });

  afterEach(() => {
    mockAdapter.restore();
    wrapper.destroy();
    wrapper = null;
  });

  describe('when loading', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('does not display the empty state', () => {
      expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
    });

    it('displays the loader', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe('when no data is present', () => {
    beforeEach(() => {
      const data = {
        groups: {
          __typename: 'Groups',
          nodes: [],
          pageInfo: {},
        },
      };
      wrapper = createComponent({ data });
    });

    it('displays the empty state', () => {
      expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(true);
    });

    it('does not display the loader', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    });
  });

  describe('when data is present', () => {
    beforeEach(() => {
      const data = {
        groups: {
          __typename: 'Groups',
          nodes: groupNodes,
          pageInfo: groupPageInfo,
        },
      };
      wrapper = createComponent({ data });
      jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore').mockReturnValue(
        new Promise(resolve => {
          resolve({
            groups: {
              __typename: 'Groups',
              nodes: [],
              pageInfo: {},
            },
          });
        }),
      );
    });

    it('does not display the empty state', () => {
      expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
    });

    it('does not display the loader', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    });

    it('should fetch more data', () => {
      expect(wrapper.vm.$apollo.queries.groups.fetchMore).toHaveBeenCalledWith(
        expect.objectContaining({
          variables: { nextPage: 2 },
        }),
      );
    });
  });

  describe('when error is thrown', () => {
    const error = 'Error: foo!';

    beforeEach(() => {
      jest.spyOn(Sentry, 'captureException');
      const data = {
        groups: {
          __typename: 'Groups',
          nodes: groupNodes,
          pageInfo: groupPageInfo,
        },
      };
      wrapper = createComponent({ data });
      jest
        .spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore')
        .mockImplementation(jest.fn().mockRejectedValue(error));
    });

    it('does not display the empty state', () => {
      expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
    });

    it('does not display the loader', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    });

    it('should fetch more data', () => {
      expect(wrapper.vm.$apollo.queries.groups.fetchMore).toHaveBeenCalledWith(
        expect.objectContaining({
          variables: { nextPage: 2 },
        }),
      );
    });

    it('displays the error message and calls Sentry', () => {
      const alert = wrapper.find(GlAlert);
      expect(alert.exists()).toBe(true);
      expect(alert.text()).toBe(DEVOPS_ADOPTION_STRINGS.app.groupsError);
      expect(Sentry.captureException).toHaveBeenCalledWith(error);
    });
  });
});
