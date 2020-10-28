import { shallowMount } from '@vue/test-utils';
import DastSiteAuthSection from 'ee/security_configuration/dast_site_profiles_form/components/dast_site_auth_section.vue';

describe('DastSiteAuthSection', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(DastSiteAuthSection);
  };

  beforeEach(() => {
    createComponent();
  });

  const findByTestId = testId => wrapper.find(`[data-testid=${testId}]`);

  describe('authentication toggle', () => {
    it('is disabled per default', () => {
      expect(findByTestId('auth-section-toggle').props('value')).toBe(false);
    });
  });
});
