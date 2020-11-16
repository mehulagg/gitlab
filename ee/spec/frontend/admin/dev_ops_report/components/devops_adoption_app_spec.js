import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import { createMockClient } from 'mock-apollo-client';
import waitForPromises from 'helpers/wait_for_promises';
import getGroupsQuery from 'ee/admin/dev_ops_report/graphql/queries/get_groups.query.graphql';
import DevopsAdoptionApp from 'ee/admin/dev_ops_report/components/devops_adoption_app.vue';
import DevopsAdoptionEmptyState from 'ee/admin/dev_ops_report/components/devops_adoption_empty_state.vue';
import { DEVOPS_ADOPTION_STRINGS } from 'ee/admin/dev_ops_report/constants';
import * as Sentry from '~/sentry/wrapper';
import { groupNodes, nextGroupNode, groupPageInfo } from '../mock_data';

const localVue = createLocalVue();
Vue.use(VueApollo);

const resolvedResponse = {
  __typename: 'Groups',
  nodes: groupNodes,
  pageInfo: groupPageInfo,
};

describe('DevopsAdoptionApp', () => {
  let wrapper;

  function createComponent(options = {}) {
    const { groupSpy } = options;
    const mockClient = createMockClient({
      resolvers: {
        Query: {
          groups: groupSpy,
        },
      },
    });

    // Necessary for local resolvers to be activated
    mockClient.cache.writeQuery({
      query: getGroupsQuery,
      data: {},
    });

    const apolloProvider = new VueApollo({
      defaultClient: mockClient,
    });

    return shallowMount(DevopsAdoptionApp, {
      localVue,
      apolloProvider,
    });
  }

  afterEach(() => {
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

  describe('initial request', () => {
    describe('when no data is present', () => {
      beforeEach(async () => {
        const groupSpy = jest.fn().mockResolvedValueOnce({ __typename: 'Groups', nodes: [] });
        wrapper = createComponent({ groupSpy });
        await waitForPromises();
      });

      it('displays the empty state', () => {
        expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(true);
      });

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });
    });

    describe('when data is present', () => {
      beforeEach(async () => {
        const groupSpy = jest.fn().mockResolvedValueOnce({ resolvedResponse, nextPage: null });
        wrapper = createComponent({ groupSpy });
        jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
        await waitForPromises();
      });

      it('does not display the empty state', () => {
        expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
      });

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });

      it('should not fetch more data', () => {
        expect(wrapper.vm.$apollo.queries.groups.fetchMore).not.toHaveBeenCalled();
      });
    });

    describe('when error is thrown', () => {
      const error = 'Error: foo!';

      beforeEach(async () => {
        jest.spyOn(Sentry, 'captureException');
        const groupSpy = jest.fn().mockRejectedValueOnce(error);
        wrapper = createComponent({ groupSpy });
        jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
        await waitForPromises();
      });

      it('does not display the empty state', () => {
        expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
      });

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });

      it('should not fetch more data', () => {
        expect(wrapper.vm.$apollo.queries.groups.fetchMore).not.toHaveBeenCalled();
      });

      it('displays the error message and calls Sentry', () => {
        const alert = wrapper.find(GlAlert);
        expect(alert.exists()).toBe(true);
        expect(alert.text()).toBe(DEVOPS_ADOPTION_STRINGS.app.groupsError);
        expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(error);
      });
    });
  });

  describe('fetchMore request', () => {
    describe('when data is present', () => {
      beforeEach(async () => {
        const groupSpy = jest
          .fn()
          .mockResolvedValueOnce(resolvedResponse)
          .mockResolvedValueOnce({ __typename: 'Groups', nodes: [nextGroupNode] });
        wrapper = createComponent({ groupSpy });
        jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
        await waitForPromises();
      });

      it('does not display the empty state', () => {
        expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
      });

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });

      it('should fetch more data', () => {
        expect(wrapper.vm.$apollo.queries.groups.fetchMore.mock.calls).toHaveLength(1);
        expect(wrapper.vm.$apollo.queries.groups.fetchMore).toHaveBeenCalledWith(
          expect.objectContaining({
            variables: { nextPage: 2 },
          }),
        );
      });
    });

    describe('when fetching too many pages of data', () => {
      beforeEach(async () => {
        // Always send the same page
        const groupSpy = jest.fn().mockResolvedValue(resolvedResponse);
        wrapper = createComponent({ groupSpy });
        jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
        wrapper.setData({ maxFetches: 2 });
        await waitForPromises();
      });

      it('does not display the empty state', () => {
        expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
      });

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });

      it('should fetch more than set by `maxFetches`', () => {
        expect(wrapper.vm.$apollo.queries.groups.fetchMore.mock.calls).toHaveLength(1);
      });
    });

    describe('when error is thrown', () => {
      const error = 'Error: foo!';

      beforeEach(async () => {
        jest.spyOn(Sentry, 'captureException');
        const groupSpy = jest
          .fn()
          .mockResolvedValueOnce(resolvedResponse)
          .mockRejectedValueOnce(error);
        wrapper = createComponent({ groupSpy });
        jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
        await waitForPromises();
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
        expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(error);
      });
    });
  });
});
