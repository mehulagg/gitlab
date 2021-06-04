import { GlDropdown } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CiTemplateDropdown from 'ee/pages/admin/application_settings/ci_cd/ci_template_dropdown.vue';

describe('CiTemplateDropdown', () => {
  let wrapper;
  const createComponent = () => {
    wrapper = shallowMount(CiTemplateDropdown);
  };

  it('has a GlDropdown', () => {
    createComponent();

    const dropdown = wrapper.findComponent(GlDropdown);

    expect(dropdown.exists()).toBe(true);
  });
});
