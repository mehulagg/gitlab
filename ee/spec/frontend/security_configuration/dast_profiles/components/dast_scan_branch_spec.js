import { GlIcon, GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import DastScanBranch from 'ee/security_configuration/dast_profiles/components/dast_scan_branch.vue';
import { savedScans } from '../mocks/mock_data';

const [scanWithExistingBranch, scanWithInexistingBranch] = savedScans;

describe('EE - DastSavedScansList', () => {
  let wrapper;

  const createWrapper = (propsData = {}) => {
    wrapper = shallowMount(DastScanBranch, {
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders branch information if it exists', () => {
    const { branch, editPath } = scanWithExistingBranch;
    createWrapper({ branch, editPath });

    expect(wrapper.text()).toContain(branch.name);
    expect(wrapper.find(GlIcon).props('name')).toBe('branch');
  });

  describe('branch does not exist', () => {
    beforeEach(() => {
      const { branch, editPath } = scanWithInexistingBranch;
      createWrapper({ branch, editPath });
    });
    it('renders a warning message', () => {
      expect(wrapper.text()).toContain('Branch missing');
      expect(wrapper.find(GlIcon).props('name')).toBe('warning');
    });

    it('renders the edit link', () => {
      const link = wrapper.find(GlLink);
      expect(link.text()).toBe('Select branch');
      expect(link.attributes('href')).toBe(scanWithInexistingBranch.editPath);
    });
  });
});
