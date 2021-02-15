import { GlAlert, GlLink, GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { merge } from 'lodash';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import App from 'ee/security_configuration/api_fuzzing/components/app.vue';
import ConfigurationForm from 'ee/security_configuration/api_fuzzing/components/configuration_form.vue';
import apiFuzzingCiConfigurationQuery from 'ee/security_configuration/api_fuzzing/graphql/api_fuzzing_ci_configuration.query.graphql';
import { stripTypenames } from 'helpers/graphql_helpers';
import createMockApollo from 'helpers/mock_apollo_helper';
import { apiFuzzingConfigurationQueryResponse } from '../mock_data';

Vue.use(VueApollo);

describe('EE - ApiFuzzingConfigurationApp', () => {
  let wrapper;
  const projectFullPath = 'namespace/project';
  const pendingHandler = jest.fn(() => new Promise(() => {}));
  const successHandler = jest.fn(async () => apiFuzzingConfigurationQueryResponse);
  const createMockApolloProvider = (handler) =>
    createMockApollo([[apiFuzzingCiConfigurationQuery, handler]]);

  const findLoadingSpinner = () => wrapper.find(GlLoadingIcon);
  const findConfigurationForm = () => wrapper.find(ConfigurationForm);

  const createWrapper = (options) => {
    wrapper = shallowMount(
      App,
      merge(
        {
          apolloProvider: () => createMockApolloProvider(successHandler),
          stubs: {
            GlSprintf,
          },
          provide: {
            fullPath: projectFullPath,
            apiFuzzingDocumentationPath: '/api_fuzzing/documentation/path',
          },
          data() {
            return {
              apiFuzzingCiConfiguration: {},
            };
          },
        },
        options,
      ),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('shows a loading spinner while fetching the configuration from the API', () => {
    createWrapper({
      apolloProvider: createMockApolloProvider(pendingHandler),
    });

    expect(pendingHandler).toHaveBeenCalledWith({ fullPath: projectFullPath });
    expect(findLoadingSpinner().exists()).toBe(true);
    expect(findConfigurationForm().exists()).toBe(false);
  });

  describe('configuration fetched successfully', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('shows the form once the configuration has loaded', () => {
      expect(findConfigurationForm().exists()).toBe(true);
      expect(findLoadingSpinner().exists()).toBe(false);
    });

    it('passes the configuration to the form', () => {
      expect(findConfigurationForm().props('apiFuzzingCiConfiguration')).toEqual(
        stripTypenames(apiFuzzingConfigurationQueryResponse.data.project.apiFuzzingCiConfiguration),
      );
    });

    it("shows a notice about the tool's purpose", () => {
      const alert = wrapper.find(GlAlert);
      expect(alert.exists()).toBe(true);
      expect(alert.text()).toBe(
        'Use this tool to generate API fuzzing configuration YAML to copy into your .gitlab-ci.yml file. This tool does not reflect or update your .gitlab-ci.yml file automatically.',
      );
    });

    it('includes a link to API fuzzing documentation ', () => {
      const link = wrapper.find(GlLink);
      expect(link.exists()).toBe(true);
      expect(link.attributes('href')).toBe('/api_fuzzing/documentation/path');
    });
  });
});
