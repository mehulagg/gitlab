import { GlAlert } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import DevopsAdoptionApp from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_app.vue';
import DevopsAdoptionSection from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_section.vue';
import DevopsAdoptionSegmentModal from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_segment_modal.vue';
import {
  DEVOPS_ADOPTION_STRINGS,
  DEFAULT_POLLING_INTERVAL,
} from 'ee/analytics/devops_report/devops_adoption/constants';
import bulkFindOrCreateDevopsAdoptionSegmentsMutation from 'ee/analytics/devops_report/devops_adoption/graphql/mutations/bulk_find_or_create_devops_adoption_segments.mutation.graphql';
import devopsAdoptionSegments from 'ee/analytics/devops_report/devops_adoption/graphql/queries/devops_adoption_segments.query.graphql';
import getGroupsQuery from 'ee/analytics/devops_report/devops_adoption/graphql/queries/get_groups.query.graphql';
import { addSegmentsToCache } from 'ee/analytics/devops_report/devops_adoption/utils/cache_updates';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import {
  groupNodes,
  nextGroupNode,
  groupPageInfo,
  devopsAdoptionSegmentsData,
  devopsAdoptionSegmentsDataEmpty,
} from '../mock_data';

jest.mock('ee/analytics/devops_report/devops_adoption/utils/cache_updates', () => ({
  addSegmentsToCache: jest.fn(),
}));

const localVue = createLocalVue();
Vue.use(VueApollo);

const initialResponse = {
  __typename: 'Groups',
  nodes: groupNodes,
  pageInfo: groupPageInfo,
};

describe('DevopsAdoptionApp', () => {
  let wrapper;

  const groupsEmpty = jest.fn().mockResolvedValue({ __typename: 'Groups', nodes: [] });
  const segmentsEmpty = jest
    .fn()
    .mockResolvedValue({ data: { devopsAdoptionSegments: devopsAdoptionSegmentsDataEmpty } });
  const addSegmentMutationSpy = jest.fn().mockResolvedValue({
    data: {
      bulkFindOrCreateDevopsAdoptionSegments: {
        segments: [devopsAdoptionSegmentsData.nodes[0]],
        errors: [],
      },
    },
  });

  function createMockApolloProvider(options = {}) {
    const {
      groupsSpy = groupsEmpty,
      segmentsSpy = segmentsEmpty,
      addSegmentsSpy = addSegmentMutationSpy,
    } = options;

    const mockApollo = createMockApollo(
      [
        [bulkFindOrCreateDevopsAdoptionSegmentsMutation, addSegmentsSpy],
        [devopsAdoptionSegments, segmentsSpy],
      ],
      {
        Query: {
          groups: groupsSpy,
        },
      },
    );

    // Necessary for local resolvers to be activated
    mockApollo.defaultClient.cache.writeQuery({
      query: getGroupsQuery,
      data: {},
    });

    return mockApollo;
  }

  function createComponent(options = {}) {
    const { mockApollo, data = {}, provide = {} } = options;

    return shallowMount(DevopsAdoptionApp, {
      localVue,
      apolloProvider: mockApollo,
      provide,
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

    it('does not render the modal', () => {
      expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(false);
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
    });

    describe('when group data is present', () => {
      beforeEach(async () => {
        groupsSpy = jest.fn().mockResolvedValueOnce({ ...initialResponse, pageInfo: null });
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo });
        await waitForPromises();
      });

      it('renders the segment modal', () => {
        expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(true);
      });

      it('should fetch data once', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(1);
      });
    });

    describe('when error is thrown in the initial request', () => {
      const error = new Error('foo!');

      beforeEach(async () => {
        jest.spyOn(Sentry, 'captureException');
        groupsSpy = jest.fn().mockRejectedValueOnce(error);
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo });
        await waitForPromises();
      });

      it('does not render the segment modal', () => {
        expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(false);
      });

      it('should fetch data once', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(1);
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
          .mockResolvedValueOnce({
            __typename: 'Groups',
            nodes: [nextGroupNode],
            nextPage: null,
          });
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo });
        await waitForPromises();
      });

      it('renders the segment modal', () => {
        expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(true);
      });

      it('should fetch data twice', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(2);
      });

      it('should fetch more data', () => {
        expect(groupsSpy.mock.calls[0][1]).toMatchObject({
          nextPage: undefined,
        });
        expect(groupsSpy.mock.calls[1][1]).toMatchObject({
          nextPage: 2,
        });
      });
    });

    describe('when fetching too many pages of data', () => {
      beforeEach(async () => {
        // Always send the same page
        groupsSpy = jest.fn().mockResolvedValue(initialResponse);
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo, data: { requestCount: 2 } });
        await waitForPromises();
      });

      it('should fetch data twice', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(2);
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
        await waitForPromises();
      });

      it('does not render the segment modal', () => {
        expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(false);
      });

      it('should fetch data twice', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(2);
      });

      it('should fetch more data', () => {
        expect(groupsSpy.mock.calls[0][1]).toMatchObject({
          nextPage: undefined,
        });
        expect(groupsSpy.mock.calls[1][1]).toMatchObject({
          nextPage: 2,
        });
      });

      it('displays the error message and calls Sentry', () => {
        const alert = wrapper.find(GlAlert);
        expect(alert.exists()).toBe(true);
        expect(alert.text()).toBe(DEVOPS_ADOPTION_STRINGS.app.groupsError);
        expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(error);
      });
    });
  });

  describe('segments data', () => {
    describe('when there is no active group', () => {
      beforeEach(async () => {
        const mockApollo = createMockApolloProvider();
        wrapper = createComponent({ mockApollo });
        await waitForPromises();
      });

      it('does not attempt to enable a group', () => {
        expect(addSegmentMutationSpy).toHaveBeenCalledTimes(0);
      });
    });

    describe('when there is an active group', () => {
      const groupGid = devopsAdoptionSegmentsData.nodes[0].namespace.id;

      describe('which is enabled', () => {
        beforeEach(async () => {
          const segmentsWithData = jest.fn().mockResolvedValue({
            data: { devopsAdoptionSegments: devopsAdoptionSegmentsData },
          });
          const mockApollo = createMockApolloProvider({
            segmentsSpy: segmentsWithData,
          });
          const provide = {
            isGroup: true,
            groupGid,
          };
          wrapper = createComponent({ mockApollo, provide });
          await waitForPromises();
          await wrapper.vm.$nextTick();
        });

        it('does not attempt to enable a group', () => {
          expect(addSegmentMutationSpy).toHaveBeenCalledTimes(0);
        });
      });

      describe('which is not enabled', () => {
        beforeEach(async () => {
          const mockApollo = createMockApolloProvider();
          const provide = {
            isGroup: true,
            groupGid,
          };
          wrapper = createComponent({ mockApollo, provide });
          await waitForPromises();
          await wrapper.vm.$nextTick();
        });

        describe('enables the group', () => {
          it('makes a request with the correct variables', () => {
            expect(addSegmentMutationSpy).toHaveBeenCalledTimes(1);
            expect(addSegmentMutationSpy).toHaveBeenCalledWith(
              expect.objectContaining({
                namespaceIds: [groupGid],
              }),
            );
          });

          it('calls addSegmentsToCache with the correct variables', () => {
            expect(addSegmentsToCache).toHaveBeenCalledTimes(1);
            expect(addSegmentsToCache).toHaveBeenCalledWith(
              expect.anything(),
              [devopsAdoptionSegmentsData.nodes[0]],
              {
                parentNamespaceId: groupGid,
                directDescendantsOnly: false,
              },
            );
          });

          describe('error handling', () => {
            const addSegmentsSpyErrorMessage = 'Error: bar!';

            beforeEach(async () => {
              jest.spyOn(Sentry, 'captureException');
              const addSegmentsSpyError = jest.fn().mockRejectedValue(addSegmentsSpyErrorMessage);
              const provide = {
                isGroup: true,
                groupGid,
              };
              const mockApollo = createMockApolloProvider({ addSegmentsSpy: addSegmentsSpyError });
              wrapper = createComponent({ mockApollo, provide });
              await waitForPromises();
              await wrapper.vm.$nextTick();
            });

            it('does not render the segment modal', () => {
              expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(false);
            });

            it('does not render the devops section', () => {
              expect(wrapper.find(DevopsAdoptionSection).exists()).toBe(false);
            });

            it('displays the error message ', () => {
              const alert = wrapper.find(GlAlert);
              expect(alert.exists()).toBe(true);
              expect(alert.text()).toBe(DEVOPS_ADOPTION_STRINGS.app.addSegmentsError);
            });

            it('calls Sentry', () => {
              expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(
                addSegmentsSpyErrorMessage,
              );
            });
          });
        });
      });
    });

    describe('when there is an error', () => {
      const segmentsErrorMessage = 'Error: bar!';

      beforeEach(async () => {
        jest.spyOn(Sentry, 'captureException');
        const segmentsError = jest.fn().mockRejectedValue(segmentsErrorMessage);
        const mockApollo = createMockApolloProvider({ segmentsSpy: segmentsError });
        wrapper = createComponent({ mockApollo });
        await waitForPromises();
      });

      it('does not render the segment modal', () => {
        expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(false);
      });

      it('does not render the devops section', () => {
        expect(wrapper.find(DevopsAdoptionSection).exists()).toBe(false);
      });

      it('displays the error message ', () => {
        const alert = wrapper.find(GlAlert);
        expect(alert.exists()).toBe(true);
        expect(alert.text()).toBe(DEVOPS_ADOPTION_STRINGS.app.segmentsError);
      });

      it('calls Sentry', () => {
        expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(segmentsErrorMessage);
      });
    });

    describe('data polling', () => {
      const mockIntervalId = 1234;

      beforeEach(async () => {
        jest.spyOn(window, 'setInterval').mockReturnValue(mockIntervalId);
        jest.spyOn(window, 'clearInterval').mockImplementation();

        wrapper = createComponent({
          mockApollo: createMockApolloProvider({
            groupsSpy: jest.fn().mockResolvedValueOnce({ ...initialResponse, pageInfo: null }),
          }),
        });

        await waitForPromises();
      });

      it('sets pollTableData interval', () => {
        expect(window.setInterval).toHaveBeenCalledWith(
          wrapper.vm.pollTableData,
          DEFAULT_POLLING_INTERVAL,
        );
        expect(wrapper.vm.pollingTableData).toBe(mockIntervalId);
      });

      it('clears pollTableData interval when destroying ', () => {
        wrapper.vm.$destroy();

        expect(window.clearInterval).toHaveBeenCalledWith(mockIntervalId);
      });
    });
  });
});
