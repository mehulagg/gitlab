import { GlTabs, GlTab } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import App from 'ee/security_configuration/dast/components/app.vue';
import DastConfigurationForm from 'ee/security_configuration/dast/components/configuration_form.vue';

describe('EE - DAST Configuration App', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(App, {
      stubs: {
        GlTab,
        GlTabs,
      },
    });
  };

  const findForm = () => wrapper.findComponent(DastConfigurationForm);
  const findTabs = () => wrapper.findAllComponents(GlTab);
  const findTabsContainer = () => wrapper.findComponent(GlTabs);

  it('mounts', () => {
    createComponent();

    expect(wrapper.exists()).toBe(true);
    expect(wrapper.text()).toContain('DAST Settings');
  });

  it('shows the tabs correctly', () => {
    createComponent();

    expect(findTabsContainer().exists()).toBe(true);
    expect(findTabs()).toHaveLength(1);
  });

  it('loads the scan configuration by default', () => {
    createComponent();

    expect(findForm().exists()).toBe(true);
  });
});
