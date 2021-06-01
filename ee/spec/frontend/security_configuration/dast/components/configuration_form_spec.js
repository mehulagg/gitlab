import { GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import ConfigurationForm from 'ee/security_configuration/dast/components/configuration_form.vue';

describe('EE - DAST Configuration Form', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(ConfigurationForm, {
      provide: {
        dastDocumentationPath: 'documentation/security/dast',
        gitlabCiYamlEditPath: '/ci/pipeline/editor',
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  it('mounts', () => {
    createComponent();

    expect(wrapper.exists()).toBe(true);
  });

  it('includes a link to DAST Configuration documentation', () => {
    createComponent();

    expect(wrapper.html()).toContain('documentation/security/dast');
  });
});
