import Approvers from 'ee/compliance_dashboard/components/merge_requests/approvers.vue';
import MergeRequestsGrid from 'ee/compliance_dashboard/components/merge_requests/grid.vue';
import Status from 'ee/compliance_dashboard/components/merge_requests/status.vue';
import BranchDetails from 'ee/compliance_dashboard/components/shared/branch_details.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { createMergeRequests, mergedAt } from '../../mock_data';

describe('MergeRequestsGrid component', () => {
  let wrapper;

  const findMergeRequestDrawerToggles = () =>
    wrapper.findAllByTestId('merge-request-drawer-toggle');
  const findMergeRequests = () => wrapper.findAllByTestId('merge-request');
  const findMergeRequestLinks = () => wrapper.findAllByTestId('merge-request-link');
  const findTime = () => wrapper.findComponent(TimeAgoTooltip);
  const findStatuses = () => wrapper.findAllComponents(Status);
  const findApprovers = () => wrapper.findComponent(Approvers);
  const findBranchDetails = () => wrapper.findComponent(BranchDetails);

  const createComponent = (mergeRequests = {}) => {
    return shallowMountExtended(MergeRequestsGrid, {
      propsData: {
        mergeRequests,
        isLastPage: false,
      },
      stubs: {
        MergeRequest: {
          props: { mergeRequest: Object },
          template: `<div data-testid="merge-request"><a href="" data-testid="merge-request-link">{{ mergeRequest.title }}</a></div>`,
        },
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when initialized', () => {
    beforeEach(() => {
      wrapper = createComponent(createMergeRequests({ count: 2, props: {} }));
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders a list of merge requests', () => {
      expect(findMergeRequests()).toHaveLength(2);
    });

    it('renders the approvers list', () => {
      expect(findApprovers().exists()).toBe(true);
    });

    it('renders the "merged at" time', () => {
      expect(findTime().props('time')).toEqual(mergedAt());
    });
  });

  describe('statuses', () => {
    const mergeRequest = createMergeRequests({ count: 1 });

    beforeEach(() => {
      wrapper = createComponent(mergeRequest);
    });

    it('passes the correct props to the statuses', () => {
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
  });

  describe('branch details', () => {
    it('does not render if there are no branch details', () => {
      wrapper = createComponent(createMergeRequests({ count: 2, props: {} }));

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

  describe.each(['click', 'keypress.enter'])('when the %s event is triggered', (event) => {
    const mergeRequest = createMergeRequests({ count: 1 });

    beforeEach(() => {
      wrapper = createComponent(mergeRequest, true);
    });

    it('toggles the drawer when a merge request drawer toggle is the target', () => {
      findMergeRequestDrawerToggles().at(0).trigger(event);

      expect(wrapper.emitted('toggleDrawer')[0][0]).toStrictEqual(mergeRequest[0]);
    });

    it('does not toggle the drawer if an inner link is the target', () => {
      findMergeRequestLinks().at(0).trigger(event);

      expect(wrapper.emitted('toggleDrawer')).toBe(undefined);
    });
  });
});
