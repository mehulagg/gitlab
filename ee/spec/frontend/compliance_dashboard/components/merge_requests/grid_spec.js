import { shallowMount } from '@vue/test-utils';

import Approvers from 'ee/compliance_dashboard/components/merge_requests/approvers.vue';
import BranchDetails from 'ee/compliance_dashboard/components/merge_requests/branch_details.vue';
import MergeRequestsGrid from 'ee/compliance_dashboard/components/merge_requests/grid.vue';
import Status from 'ee/compliance_dashboard/components/merge_requests/status.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

import { createMergeRequests, mergedAt } from '../../mock_data';

describe('MergeRequestsGrid component', () => {
  let wrapper;

  const findMergeRequests = () => wrapper.findAll('[data-testid="merge-request"]');
  const findTime = () => wrapper.find(TimeAgoTooltip);
  const findStatuses = () => wrapper.findAll(Status);
  const findApprovers = () => wrapper.find(Approvers);
  const findBranchDetails = () => wrapper.find(BranchDetails);

  const createComponent = (mergeRequests = {}) => {
    return shallowMount(MergeRequestsGrid, {
      propsData: {
        mergeRequests,
        isLastPage: false,
      },
      stubs: {
        MergeRequest: {
          props: { mergeRequest: Object },
          template: `<div data-testid="merge-request">{{ mergeRequest.title }}</div>`,
        },
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when intialized', () => {
    beforeEach(() => {
      wrapper = createComponent(createMergeRequests({ count: 2, props: {} }));
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders a list of merge requests', () => {
      expect(findMergeRequests()).toHaveLength(2);
    });

    it('passes the correct props to the statuses', () => {
      const mergeRequest = createMergeRequests({ count: 1 });
      wrapper = createComponent(mergeRequest);

      findStatuses().wrappers.forEach((status) => {
        const { type, data } = status.props('status');

        switch (type) {
          case 'pipeline':
            expect(data).toEqual(mergeRequest[0].pipeline_status);
            break;

          case 'approval':
            expect(data).toEqual(mergeRequest[0].approval_status);
            break;

          default:
            throw new Error('Unknown status type');
        }
      });
    });

    describe('branch details', () => {
      it('does not render if there are no branch details', () => {
        expect(findBranchDetails().exists()).toBe(false);
      });

      it('renders if there are branch details', () => {
        wrapper = createComponent(
          createMergeRequests({
            count: 2,
            props: { target_branch: 'main', source_branch: 'feature' },
          }),
        );
        expect(findBranchDetails().exists()).toBe(true);
      });
    });

    it('renders the approvers list', () => {
      expect(findApprovers().exists()).toBe(true);
    });

    it('renders the "merged at" time', () => {
      expect(findTime().props('time')).toEqual(mergedAt());
    });
  });
});
