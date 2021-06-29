import { shallowMount } from '@vue/test-utils';
import BranchPath from 'ee/compliance_dashboard/components/drawer_sections/branch_path.vue';
import BranchDetails from 'ee/compliance_dashboard/components/shared/branch_details.vue';
import DrawerSectionHeader from 'ee/compliance_dashboard/components/shared/drawer_section_header.vue';

describe('BranchPath component', () => {
  let wrapper;
  const sourceBranch = 'feature-branch';
  const sourceBranchUri = '/project/feature-branch';
  const targetBranch = 'main';
  const targetBranchUri = '/project/main';

  const findSectionHeader = () => wrapper.findComponent(DrawerSectionHeader);
  const findBranchDetails = () => wrapper.findComponent(BranchDetails);

  const createComponent = (propsData = {}) => {
    return shallowMount(BranchPath, { propsData });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('does not render the section if the branches are not given', () => {
    wrapper = createComponent();

    expect(findSectionHeader().exists()).toBe(false);
    expect(findBranchDetails().exists()).toBe(false);
  });

  describe('with branches', () => {
    beforeEach(() => {
      wrapper = createComponent({ sourceBranch, sourceBranchUri, targetBranch, targetBranchUri });
    });

    it('renders the header', () => {
      expect(findSectionHeader().text()).toBe('Path');
    });

    it('renders the branch details', () => {
      expect(findBranchDetails().props()).toStrictEqual({
        sourceBranch: { name: sourceBranch, uri: sourceBranchUri },
        targetBranch: { name: targetBranch, uri: targetBranchUri },
      });
    });
  });
});
