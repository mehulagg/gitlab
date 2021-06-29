import { GlDrawer } from '@gitlab/ui';
import MergeRequestDrawer from 'ee/compliance_dashboard/components/drawer.vue';
import BranchPath from 'ee/compliance_dashboard/components/drawer_sections/branch_path.vue';
import Project from 'ee/compliance_dashboard/components/drawer_sections/project.vue';
import Reference from 'ee/compliance_dashboard/components/drawer_sections/reference.vue';
import { complianceFramework } from 'ee_jest/vue_shared/components/compliance_framework_label/mock_data';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { createMergeRequests } from '../mock_data';

describe('MergeRequestDrawer component', () => {
  let wrapper;
  const mergeRequest = createMergeRequests({
    count: 1,
    props: {
      compliance_management_framework: complianceFramework,
      source_branch: 'feature-branch',
      source_branch_uri: '/project/feature-branch',
      target_branch: 'main',
      target_branch_uri: '/project/main',
    },
  })[0];

  const findTitle = () => wrapper.findByTestId('dashboard-drawer-title');
  const findDrawer = () => wrapper.findComponent(GlDrawer);
  const findProject = () => wrapper.findComponent(Project);
  const findReference = () => wrapper.findComponent(Reference);
  const findBranchPath = () => wrapper.findComponent(BranchPath);

  const createComponent = (props) => {
    return shallowMountExtended(MergeRequestDrawer, {
      propsData: {
        mergeRequest,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when closed', () => {
    beforeEach(() => {
      wrapper = createComponent({ showDrawer: false });
    });

    it('the drawer is not shown', () => {
      expect(findDrawer().props('open')).toBe(false);
    });

    it('the sections are not mounted', () => {
      expect(findProject().exists()).toBe(false);
    });
  });

  describe('when open', () => {
    beforeEach(() => {
      wrapper = createComponent({ showDrawer: true });
    });

    it('the drawer is shown', () => {
      expect(findDrawer().props('open')).toBe(true);
    });

    it('has the drawer title', () => {
      expect(findTitle().text()).toEqual(mergeRequest.title);
    });

    it('has the project section', () => {
      expect(findProject().props()).toStrictEqual({
        avatarUrl: mergeRequest.project.avatar_url,
        complianceFramework,
        name: mergeRequest.project.name,
        url: mergeRequest.project.web_url,
      });
    });

    it('has the reference section', () => {
      expect(findReference().props()).toStrictEqual({
        path: mergeRequest.path,
        reference: mergeRequest.reference,
      });
    });

    it('has the branch path section', () => {
      expect(findBranchPath().props()).toStrictEqual({
        sourceBranch: mergeRequest.source_branch,
        sourceBranchUri: mergeRequest.source_branch_uri,
        targetBranch: mergeRequest.target_branch,
        targetBranchUri: mergeRequest.target_branch_uri,
      });
    });
  });
});
