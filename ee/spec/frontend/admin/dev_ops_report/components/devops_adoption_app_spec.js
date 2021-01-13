import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlAlert, GlButton, GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import { getByText } from '@testing-library/dom';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import getGroupsQuery from 'ee/admin/dev_ops_report/graphql/queries/get_groups.query.graphql';
import devopsAdoptionSegments from 'ee/admin/dev_ops_report/graphql/queries/devops_adoption_segments.query.graphql';
import DevopsAdoptionApp from 'ee/admin/dev_ops_report/components/devops_adoption_app.vue';
import DevopsAdoptionEmptyState from 'ee/admin/dev_ops_report/components/devops_adoption_empty_state.vue';
import DevopsAdoptionTable from 'ee/admin/dev_ops_report/components/devops_adoption_table.vue';
import DevopsAdoptionSegmentModal from 'ee/admin/dev_ops_report/components/devops_adoption_segment_modal.vue';
import {
  DEVOPS_ADOPTION_STRINGS,
  DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
  MAX_SEGMENTS,
} from 'ee/admin/dev_ops_report/constants';
import * as Sentry from '~/sentry/wrapper';
import {
  groupNodes,
  nextGroupNode,
  groupPageInfo,
  devopsAdoptionSegmentsData,
  devopsAdoptionSegmentsDataEmpty,
} from '../mock_data';

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

  function createMockApolloProvider(options = {}) {
    const { groupsSpy = groupsEmpty, segmentsSpy = segmentsEmpty } = options;

    const mockApollo = createMockApollo([[devopsAdoptionSegments, segmentsSpy]], {
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
      stubs: {
        GlSprintf,
      },
      directives: {
        GlTooltip: createMockDirective(),
      },
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

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
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

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
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
    describe('when loading', () => {
      beforeEach(async () => {
        const segmentsLoading = jest.fn().mockResolvedValue(new Promise(() => {}));
        const mockApollo = createMockApolloProvider({ segmentsSpy: segmentsLoading });
        wrapper = createComponent({ mockApollo });
        await waitForPromises();
      });

      it('does not display the empty state', () => {
        expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
      });

      it('displays the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
      });
    });

    describe('when there is no segment data', () => {
      beforeEach(async () => {
        const mockApollo = createMockApolloProvider();
        wrapper = createComponent({ mockApollo });
        await waitForPromises();
      });

      it('displays the empty state', () => {
        expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(true);
      });

      it('does not display the table', () => {
        expect(wrapper.find(DevopsAdoptionTable).exists()).toBe(false);
      });
    });

    describe('when there is segment data', () => {
      beforeEach(async () => {
        const segmentsWithData = jest
          .fn()
          .mockResolvedValue({ data: { devopsAdoptionSegments: devopsAdoptionSegmentsData } });
        const mockApollo = createMockApolloProvider({ segmentsSpy: segmentsWithData });
        wrapper = createComponent({ mockApollo });
        await waitForPromises();
      });

      it('does not display the empty state', () => {
        expect(wrapper.find(DevopsAdoptionEmptyState).exists()).toBe(false);
      });

      it('displays the table', () => {
        expect(wrapper.find(DevopsAdoptionTable).exists()).toBe(true);
      });

      describe('table header', () => {
        let tableHeader;

        beforeEach(() => {
          tableHeader = wrapper.find("[data-testid='tableHeader']");
        });

        afterEach(() => {
          tableHeader = null;
        });

        it('displays the table header', () => {
          expect(tableHeader.exists()).toBe(true);
        });

        it('displays the header text', () => {
          const text =
            'Feature adoption is based on usage in the last calendar month. Last updated: 2020-10-31 23:59.';
          expect(getByText(wrapper.element, text)).not.toBeNull();
        });

        describe('segment modal button', () => {
          let segmentButton;
          let segmentButtonWrapper;

          beforeEach(() => {
            segmentButton = tableHeader.find(GlButton);
            segmentButtonWrapper = wrapper.find("[data-testid='segmentButtonWrapper']");
          });

          afterEach(() => {
            segmentButton = null;
          });

          it('displays the add segment button', () => {
            expect(segmentButton.exists()).toBe(true);
          });

          it('calls the gl-modal show', async () => {
            const rootEmit = jest.spyOn(wrapper.vm.$root, '$emit');

            segmentButton.trigger('click');

            expect(rootEmit.mock.calls[0][0]).toContain('show');
            expect(rootEmit.mock.calls[0][1]).toBe(DEVOPS_ADOPTION_SEGMENT_MODAL_ID);
          });

          it('does not have a tooltip', () => {
            const tooltip = getBinding(segmentButtonWrapper.element, 'gl-tooltip');

            // Setting a directive's value to false tells it not to render
            expect(tooltip.value).toBe(false);
          });

          describe('when there are more than the max number of segments', () => {
            beforeEach(() => {
              const data = {
                nodes: Array(MAX_SEGMENTS + 1).fill(devopsAdoptionSegmentsData.nodes[0]),
              };
              wrapper.setData({ devopsAdoptionSegments: data });
            });

            it('disables the button', () => {
              expect(segmentButton.props('disabled')).toBe(true);
            });

            it('has a tooltip', () => {
              const tooltip = getBinding(segmentButtonWrapper.element, 'gl-tooltip');

              expect(tooltip).toBeDefined();
              expect(tooltip.value).toBe('Maximum 30 groups allowed');
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

      it('does not display the loader', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
      });

      it('does not render the segment modal', () => {
        expect(wrapper.find(DevopsAdoptionSegmentModal).exists()).toBe(false);
      });

      it('does not render the table', () => {
        expect(wrapper.find(DevopsAdoptionTable).exists()).toBe(false);
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
  });
});
