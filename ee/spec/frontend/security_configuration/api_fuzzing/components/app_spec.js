import { shallowMount } from '@vue/test-utils';
import { GlAlert, GlLink, GlLoadingIcon, GlSprintf } from '@gitlab/ui';

import App from 'ee/security_configuration/api_fuzzing/components/app.vue';
import ConfigurationForm from 'ee/security_configuration/api_fuzzing/components/configuration_form.vue';

describe('EE - ApiFuzzingConfigurationApp', () => {
  let wrapper;

  const findLoadingSpinner = () => wrapper.find(GlLoadingIcon);
  const findConfigurationForm = () => wrapper.find(ConfigurationForm);

  const createWrapper = ({ loading = false } = {}) => {
    const $apollo = {
      loading,
    };

    wrapper = shallowMount(App, {
      stubs: {
        GlSprintf,
      },
      provide: {
        fullPath: 'namespace/project',
        apiFuzzingDocumentationPath: '/api_fuzzing/documentation/path',
      },
      mocks: {
        $apollo,
      },
      data() {
        return {
          apiFuzzingCiConfiguration: {},
        };
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('shows a loading spinner while fetching the configuration from the API', () => {
    createWrapper({ loading: true });

    expect(findLoadingSpinner().exists()).toBe(true);
    expect(findConfigurationForm().exists()).toBe(false);
  });

  it('shows the form once the configuration has loaded', () => {
    createWrapper();

    expect(findConfigurationForm().exists()).toBe(true);
    expect(findLoadingSpinner().exists()).toBe(false);
  });

  it("shows a notice about the tool's purpose", () => {
    createWrapper();

    const alert = wrapper.find(GlAlert);
    expect(alert.exists()).toBe(true);
    expect(alert.text()).toBe(
      'Use this tool to generate API fuzzing configuration YAML to copy into your .gitlab-ci.yml file. This tool does not reflect or update your .gitlab-ci.yml file automatically.',
    );
  });

  it('includes a link to API fuzzing documentation ', () => {
    createWrapper();

    const link = wrapper.find(GlLink);
    expect(link.exists()).toBe(true);
    expect(link.attributes('href')).toBe('/api_fuzzing/documentation/path');
  });
});
