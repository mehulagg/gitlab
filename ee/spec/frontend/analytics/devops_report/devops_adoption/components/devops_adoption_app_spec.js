import { GlAlert, GlTabs } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { createLocalVue } from '@vue/test-utils';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import DevopsAdoptionAddDropdown from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_add_dropdown.vue';
import DevopsAdoptionApp from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_app.vue';
import DevopsAdoptionOverview from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_overview.vue';
import DevopsAdoptionSection from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_section.vue';
import {
  DEVOPS_ADOPTION_STRINGS,
  DEFAULT_POLLING_INTERVAL,
  DEVOPS_ADOPTION_TABLE_CONFIGURATION,
} from 'ee/analytics/devops_report/devops_adoption/constants';
import bulkEnableDevopsAdoptionNamespacesMutation from 'ee/analytics/devops_report/devops_adoption/graphql/mutations/bulk_enable_devops_adoption_namespaces.mutation.graphql';
import devopsAdoptionEnabledNamespaces from 'ee/analytics/devops_report/devops_adoption/graphql/queries/devops_adoption_enabled_namespaces.query.graphql';
import getGroupsQuery from 'ee/analytics/devops_report/devops_adoption/graphql/queries/get_groups.query.graphql';
import { addSegmentsToCache } from 'ee/analytics/devops_report/devops_adoption/utils/cache_updates';
import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import DevopsScore from '~/analytics/devops_report/components/devops_score.vue';
import API from '~/api';
import {
  groupNodes,
  groupPageInfo,
  devopsAdoptionNamespaceData,
  devopsAdoptionNamespaceDataEmpty,
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
  const segmentsEmpty = jest.fn().mockResolvedValue({
    data: { devopsAdoptionEnabledNamespaces: devopsAdoptionNamespaceDataEmpty },
  });
  const addSegmentMutationSpy = jest.fn().mockResolvedValue({
    data: {
      bulkEnableDevopsAdoptionNamespaces: {
        enabledNamespaces: [devopsAdoptionNamespaceData.nodes[0]],
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
        [bulkEnableDevopsAdoptionNamespacesMutation, addSegmentsSpy],
        [devopsAdoptionEnabledNamespaces, segmentsSpy],
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

    return shallowMountExtended(DevopsAdoptionApp, {
      localVue,
      apolloProvider: mockApollo,
      provide,
      data() {
        return data;
      },
      stubs: {
        GlTabs,
      },
    });
  }

  const findDevopsScoreTab = () => wrapper.findByTestId('devops-score-tab');
  const findOverviewTab = () => wrapper.findByTestId('devops-overview-tab');

  afterEach(() => {
    wrapper.destroy();
  });

  describe('group data request', () => {
    let groupsSpy;

    afterEach(() => {
      groupsSpy = null;
    });

    describe('when group data is present', () => {
      beforeEach(async () => {
        groupsSpy = jest.fn().mockResolvedValueOnce({ ...initialResponse, pageInfo: null });
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo });
        await waitForPromises();
      });

      it('should fetch data once', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(1);
      });
    });

    describe('when error is thrown fetching group data', () => {
      const error = new Error('foo!');

      beforeEach(async () => {
        jest.spyOn(Sentry, 'captureException');
        groupsSpy = jest.fn().mockRejectedValueOnce(error);
        const mockApollo = createMockApolloProvider({ groupsSpy });
        wrapper = createComponent({ mockApollo });
        await waitForPromises();
      });

      it('should fetch data once', () => {
        expect(groupsSpy).toHaveBeenCalledTimes(1);
      });

      it('displays the error message and calls Sentry', () => {
        const alert = wrapper.findComponent(GlAlert);
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
      const groupGid = devopsAdoptionNamespaceData.nodes[0].namespace.id;

      describe('which is enabled', () => {
        beforeEach(async () => {
          const segmentsWithData = jest.fn().mockResolvedValue({
            data: { devopsAdoptionEnabledNamespaces: devopsAdoptionNamespaceData },
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
                displayNamespaceId: groupGid,
              }),
            );
          });

          it('calls addSegmentsToCache with the correct variables', () => {
            expect(addSegmentsToCache).toHaveBeenCalledTimes(1);
            expect(addSegmentsToCache).toHaveBeenCalledWith(
              expect.anything(),
              [devopsAdoptionNamespaceData.nodes[0]],
              {
                displayNamespaceId: groupGid,
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

            it('does not render the devops section', () => {
              expect(wrapper.findComponent(DevopsAdoptionSection).exists()).toBe(false);
            });

            it('displays the error message ', () => {
              const alert = wrapper.findComponent(GlAlert);
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

      it('does not render the devops section', () => {
        expect(wrapper.findComponent(DevopsAdoptionSection).exists()).toBe(false);
      });

      it('displays the error message ', () => {
        const alert = wrapper.findComponent(GlAlert);
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

  describe('tabs', () => {
    const eventTrackingBehaviour = (testId, event) => {
      describe('event tracking', () => {
        it(`tracks the ${event} event when clicked`, () => {
          jest.spyOn(API, 'trackRedisHllUserEvent');

          expect(API.trackRedisHllUserEvent).not.toHaveBeenCalled();

          wrapper.findByTestId(testId).vm.$emit('click');

          expect(API.trackRedisHllUserEvent).toHaveBeenCalledWith(event);
        });

        it('only tracks the event once', () => {
          jest.spyOn(API, 'trackRedisHllUserEvent');

          expect(API.trackRedisHllUserEvent).not.toHaveBeenCalled();

          const { vm } = wrapper.findByTestId(testId);
          vm.$emit('click');
          vm.$emit('click');

          expect(API.trackRedisHllUserEvent).toHaveBeenCalledTimes(1);
        });
      });
    };

    const defaultDevopsAdoptionTabBehavior = () => {
      describe('overview tab', () => {
        it('displays the overview tab', () => {
          expect(findOverviewTab().exists()).toBe(true);
        });

        it('displays the devops adoption overview component', () => {
          expect(findOverviewTab().findComponent(DevopsAdoptionOverview).exists()).toBe(true);
        });
      });

      describe('devops adoption tabs', () => {
        it('displays the configured number of tabs', () => {
          expect(wrapper.findAllByTestId('devops-adoption-tab')).toHaveLength(
            DEVOPS_ADOPTION_TABLE_CONFIGURATION.length,
          );
        });

        it('displays the devops section component with the tab', () => {
          expect(
            wrapper
              .findByTestId('devops-adoption-tab')
              .findComponent(DevopsAdoptionSection)
              .exists(),
          ).toBe(true);
        });

        it('displays the DevopsAdoptionAddDropdown as the last tab', () => {
          expect(wrapper.findComponent(DevopsAdoptionAddDropdown).exists()).toBe(true);
        });

        eventTrackingBehaviour('devops-adoption-tab', 'i_analytics_dev_ops_adoption');
      });
    };

    describe('admin level', () => {
      beforeEach(() => {
        const mockApollo = createMockApolloProvider();
        wrapper = createComponent({ mockApollo });
      });

      defaultDevopsAdoptionTabBehavior();

      describe('devops score tab', () => {
        it('displays the devops score tab', () => {
          expect(findDevopsScoreTab().exists()).toBe(true);
        });

        it('displays the devops score component', () => {
          expect(findDevopsScoreTab().findComponent(DevopsScore).exists()).toBe(true);
        });

        eventTrackingBehaviour('devops-score-tab', 'i_analytics_dev_ops_score');
      });
    });

    describe('group level', () => {
      beforeEach(() => {
        const mockApollo = createMockApolloProvider();
        wrapper = createComponent({
          mockApollo,
          provide: {
            isGroup: true,
            groupGid: devopsAdoptionNamespaceData.nodes[0].namespace.id,
          },
        });
      });

      defaultDevopsAdoptionTabBehavior();

      it('does not display the devops score tab', () => {
        expect(findDevopsScoreTab().exists()).toBe(false);
      });
    });
  });
});
