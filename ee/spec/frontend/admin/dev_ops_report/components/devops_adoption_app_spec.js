import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import MockAdapter from 'axios-mock-adapter';
import VueApollo from 'vue-apollo';
import { createMockClient } from 'mock-apollo-client';
import Api from 'ee/api';
import { resolvers as devOpsResolvers } from 'ee/admin/dev_ops_report/graphql';
import getGroupsQuery from 'ee/admin/dev_ops_report/graphql/queries/get_groups.query.graphql';
import DevopsAdoptionApp from 'ee/admin/dev_ops_report/components/devops_adoption_app.vue';
import DevopsAdoptionEmptyState from 'ee/admin/dev_ops_report/components/devops_adoption_empty_state.vue';
import { DEVOPS_ADOPTION_STRINGS } from 'ee/admin/dev_ops_report/constants';
import httpStatus from '~/lib/utils/http_status';
import axios from '~/lib/utils/axios_utils';
import * as Sentry from '~/sentry/wrapper';
import { groupData, pageData, groupNodes, groupPageInfo } from '../mock_data';

const groupsUrl = Api.buildUrl(Api.groupsPath);

const localVue = createLocalVue();

describe('DevopsAdoptionApp', () => {
  let wrapper;
  let mockAdapter;

  const createComponent = (options = {}) => {
    const { data = {}, variables = {} } = options;

    const mockClient = createMockClient({
      resolvers: devOpsResolvers,
    });

    mockClient.cache.writeQuery({
      query: getGroupsQuery,
      // variables,
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
    beforeEach(async () => {
      mockAdapter.onGet(groupsUrl).reply(httpStatus.OK, [], {});
      const data = {
        groups: {
          __typename: 'Groups',
          nodes: [],
          pageInfo: {},
        },
      };
      wrapper = createComponent({ data });
      await wrapper.vm.$nextTick();
      await wrapper.vm.$nextTick();
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
      mockAdapter.onGet(groupsUrl).reply(httpStatus.OK, groupData, pageData);
      const data = {
        groups: {
          __typename: 'Groups',
          nodes: groupNodes,
          pageInfo: groupPageInfo,
        },
      };
      const variables = groupPageInfo;
      wrapper = createComponent({ data, variables });
      jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
    });

    it('does not display the empty state', () => {
      expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
    });

    it('does not display the loader', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    });

    it.only('should fetch more data', () => {
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
      mockAdapter.onGet(groupsUrl).reply(httpStatus.FORBIDDEN, {}, {});
      jest.spyOn(Sentry, 'captureException');
      const data = {
        groups: {
          __typename: 'Groups',
          nodes: groupNodes,
          pageInfo: groupPageInfo,
        },
      };
      wrapper = createComponent({ data });
      jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
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
