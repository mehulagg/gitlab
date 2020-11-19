import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import getGroupsQuery from 'ee/admin/dev_ops_report/graphql/queries/get_groups.query.graphql';
import DevopsAdoptionApp from 'ee/admin/dev_ops_report/components/devops_adoption_app.vue';
import DevopsAdoptionEmptyState from 'ee/admin/dev_ops_report/components/devops_adoption_empty_state.vue';
import DevopsAdoptionSegmentModal from 'ee/admin/dev_ops_report/components/devops_adoption_segment_modal.vue';
import { DEVOPS_ADOPTION_STRINGS } from 'ee/admin/dev_ops_report/constants';
import * as Sentry from '~/sentry/wrapper';
import { groupNodes, nextGroupNode, groupPageInfo } from '../mock_data';

const localVue = createLocalVue();
Vue.use(VueApollo);

const initialResponse = {
  __typename: 'Groups',
  nodes: groupNodes,
  pageInfo: groupPageInfo,
};

describe('DevopsAdoptionApp', () => {
  let wrapper;

  function createMockApolloProvider(options = {}) {
    const { groupsSpy } = options;
    const mockApollo = createMockApollo([], {
      Query: {
        groups: groupsSpy,
      },
    });

    // Necessary for local resolvers to be activated
    mockApollo.defaultClient.cache.writeQuery({
      query: getGroupsQuery,
      data: {},
    });

    return mockApollo;
  }

  function createComponent(options = {}) {
    const { mockApollo, data = {} } = options;

    return shallowMount(DevopsAdoptionApp, {
      localVue,
      apolloProvider: mockApollo,
      data() {
        return data;
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when loading', () => {
    beforeEach(() => {
      const mockApollo = createMockApolloProvider();
      wrapper = createComponent({ mockApollo });
    });

    it('does not display the empty state', () => {
      expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
    });

    it('displays the loader', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe('initial request', () => {
    let groupsSpy;

    afterEach(() => {
      groupsSpy = null;
    });

    describe('when no group data is present', () => {
      beforeEach(async () => {
        groupsSpy = jest.fn().mockResolvedValueOnce({ __typename: 'Groups', nodes: [] });
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo });
        await waitForPromises();
      });

      it('does not render the segment modal', () => {
        expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(false);
      });

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });
    });

    describe('when group data is present', () => {
      beforeEach(async () => {
        groupsSpy = jest.fn().mockResolvedValueOnce({ ...initialResponse, pageInfo: null });
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo });
        jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
        await waitForPromises();
      });

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });

      it('renders the segment modal', () => {
        expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(true);
      });

      it('should fetch data once', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(1);
      });

      it('should not fetch more data', () => {
        expect(wrapper.vm.$apollo.queries.groups.fetchMore).not.toHaveBeenCalled();
      });
    });

    describe('when error is thrown in the initial request', () => {
      const error = 'Error: foo!';

      beforeEach(async () => {
        jest.spyOn(Sentry, 'captureException');
        groupsSpy = jest.fn().mockRejectedValueOnce(error);
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo });
        jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
        await waitForPromises();
      });

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });

      it('does not render the segment modal', () => {
        expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(false);
      });

      it('should fetch data once', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(1);
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
    let groupsSpy;

    afterEach(() => {
      groupsSpy = null;
    });

    describe('when group data is present', () => {
      beforeEach(async () => {
        groupsSpy = jest
          .fn()
          .mockResolvedValueOnce(initialResponse)
          // `fetchMore` response
          .mockResolvedValueOnce({ __typename: 'Groups', nodes: [nextGroupNode], nextPage: null });
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo });
        jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
        await waitForPromises();
      });

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });

      it('renders the segment modal', () => {
        expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(true);
      });

      it('should fetch data twice', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(2);
      });

      it('should fetch more data', () => {
        expect(wrapper.vm.$apollo.queries.groups.fetchMore).toHaveBeenCalledTimes(1);
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
        groupsSpy = jest.fn().mockResolvedValue(initialResponse);
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo, data: { requestCount: 2 } });
        jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
        await waitForPromises();
      });

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });

      it('should fetch data twice', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(2);
      });

      it('should not fetch more than `requestCount`', () => {
        expect(wrapper.vm.$apollo.queries.groups.fetchMore).toHaveBeenCalledTimes(1);
      });
    });

    describe('when error is thrown in the fetchMore request', () => {
      const error = 'Error: foo!';

      beforeEach(async () => {
        jest.spyOn(Sentry, 'captureException');
        groupsSpy = jest
          .fn()
          .mockResolvedValueOnce(initialResponse)
          // `fetchMore` response
          .mockRejectedValue(error);
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo });
        jest.spyOn(wrapper.vm.$apollo.queries.groups, 'fetchMore');
        await waitForPromises();
      });

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });

      it('does not render the segment modal', () => {
        expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(false);
      });

      it('should fetch data twice', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(2);
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
