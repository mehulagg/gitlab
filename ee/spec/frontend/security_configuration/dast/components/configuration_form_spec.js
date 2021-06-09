import { GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import ConfigurationForm from 'ee/security_configuration/dast/components/configuration_form.vue';
import { DAST_HELP_PATH } from '~/security_configuration/components/constants';

describe('EE - DAST Configuration Form', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(ConfigurationForm, {
      stubs: {
        GlSprintf,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('mounts', () => {
    expect(wrapper.exists()).toBe(true);
  });

  it('includes a link to DAST Configuration documentation', () => {
    expect(wrapper.html()).toContain(DAST_HELP_PATH);
  });
});
