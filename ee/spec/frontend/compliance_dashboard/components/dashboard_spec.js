import { GlTabs, GlTab } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Cookies from 'js-cookie';

import ComplianceDashboard from 'ee/compliance_dashboard/components/dashboard.vue';
import MergeRequestGrid from 'ee/compliance_dashboard/components/merge_requests/grid.vue';
import MergeCommitsExportButton from 'ee/compliance_dashboard/components/merge_requests/merge_commits_export_button.vue';
import { COMPLIANCE_TAB_COOKIE_KEY } from 'ee/compliance_dashboard/constants';
import { createMergeRequests } from '../mock_data';

describe('ComplianceDashboard component', () => {
  let wrapper;

  const isLastPage = false;
  const mergeRequests = createMergeRequests({ count: 2 });
  const mergeCommitsCsvExportPath = '/csv';

  const findMergeRequestsGrid = () => wrapper.find(MergeRequestGrid);
  const findMergeCommitsExportButton = () => wrapper.find(MergeCommitsExportButton);
  const findDashboardTabs = () => wrapper.find(GlTabs);

  const createComponent = (props = {}) => {
    return shallowMount(ComplianceDashboard, {
      propsData: {
        mergeRequests,
        isLastPage,
        mergeCommitsCsvExportPath,
        emptyStateSvgPath: 'empty.svg',
        ...props,
      },
      stubs: {
        GlTab,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when there are merge requests', () => {
    beforeEach(() => {
      Cookies.set(COMPLIANCE_TAB_COOKIE_KEY, false);
      wrapper = createComponent();
    });

    afterEach(() => {
      Cookies.remove(COMPLIANCE_TAB_COOKIE_KEY);
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders the merge requests', () => {
      expect(findMergeRequestsGrid().exists()).toBe(true);
    });

    it('sets the MergeRequestGrid properties', () => {
      expect(findMergeRequestsGrid().props('mergeRequests')).toBe(mergeRequests);
      expect(findMergeRequestsGrid().props('isLastPage')).toBe(isLastPage);
    });

    it('renders the merge commit export button', () => {
      expect(findMergeCommitsExportButton().exists()).toBe(true);
    });

    describe('and the show tabs cookie is true', () => {
      beforeEach(() => {
        Cookies.set(COMPLIANCE_TAB_COOKIE_KEY, true);
        wrapper = createComponent();
      });

      it('matches the snapshot', () => {
        expect(wrapper.element).toMatchSnapshot();
      });

      it('renders the dashboard tabs', () => {
        expect(findDashboardTabs().exists()).toBe(true);
      });
    });
  });

  describe('when there are no merge requests', () => {
    beforeEach(() => {
      wrapper = createComponent({ mergeRequests: [] });
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('does not render merge requests', () => {
      expect(findMergeRequestsGrid().exists()).toBe(false);
    });
  });

  describe('when the merge commit export link is not present', () => {
    beforeEach(() => {
      wrapper = createComponent({ mergeCommitsCsvExportPath: '' });
    });

    it('does not render the merge commit export button', () => {
      return wrapper.vm.$nextTick().then(() => {
        expect(findMergeCommitsExportButton().exists()).toBe(false);
      });
    });
  });
});
