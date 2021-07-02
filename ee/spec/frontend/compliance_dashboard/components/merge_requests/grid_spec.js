import Approvers from 'ee/compliance_dashboard/components/merge_requests/approvers.vue';
import BranchDetails from 'ee/compliance_dashboard/components/merge_requests/branch_details.vue';
import MergeRequestsGrid from 'ee/compliance_dashboard/components/merge_requests/grid.vue';
import Status from 'ee/compliance_dashboard/components/merge_requests/status.vue';
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

  const createComponent = (mergeRequests = {}, drawerEnabled = false) => {
    return shallowMountExtended(MergeRequestsGrid, {
      propsData: {
        mergeRequests,
        isLastPage: false,
        drawerEnabled,
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

  // TODO: Remove the each with https://gitlab.com/gitlab-org/gitlab/-/issues/334682
  describe.each([true, false])('when drawer enabled is %s', (drawerEnabled) => {
    describe('when initialized', () => {
      beforeEach(() => {
        wrapper = createComponent(createMergeRequests({ count: 2, props: {} }), drawerEnabled);
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
        wrapper = createComponent(mergeRequest, drawerEnabled);
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
        wrapper = createComponent(createMergeRequests({ count: 2, props: {} }), drawerEnabled);

        expect(findBranchDetails().exists()).toBe(false);
      });

      it('renders if there are branch details', () => {
        wrapper = createComponent(
          createMergeRequests({
            count: 2,
            props: { target_branch: 'main', source_branch: 'feature' },
          }),
          drawerEnabled,
        );

        expect(findBranchDetails().exists()).toBe(true);
      });
    });
  });

  describe('when the drawer is enabled', () => {
    const mergeRequests = createMergeRequests({ count: 2, props: {} });

    beforeEach(() => {
      const mergeRequest = createMergeRequests({ count: 1 });
      wrapper = createComponent(mergeRequest, true);
    });

    it('toggles the drawer when a merge request drawer toggle is clicked', () => {
      findMergeRequestDrawerToggles().at(0).trigger('click');

      expect(wrapper.emitted('toggleDrawer')[0][0]).toStrictEqual(mergeRequests[0]);
    });

    it('does not toggle the drawer if an inner link is clicked', () => {
      findMergeRequestLinks().at(0).trigger('click');

      expect(wrapper.emitted('toggleDrawer')).toBe(undefined);
    });
  });
});
