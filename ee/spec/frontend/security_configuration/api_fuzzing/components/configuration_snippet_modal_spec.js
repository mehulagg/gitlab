import { shallowMount } from '@vue/test-utils';
import { merge } from 'lodash';
import Clipboard from 'clipboard';
import { GlModal } from '@gitlab/ui';
import { redirectTo } from '~/lib/utils/url_utility';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import ConfigurationSnippetModal from 'ee/security_configuration/api_fuzzing/components/configuration_snippet_modal.vue';
import { createApiFuzzingConfigurationMutationResponse } from '../mock_data';

jest.mock('clipboard', () =>
  jest.fn().mockImplementation(() => ({
    on: jest.fn().mockImplementation((_event, cb) => cb()),
  })),
);
jest.mock('~/lib/utils/url_utility', () => ({
  redirectTo: jest.fn(),
}));

const {
  gitlabCiYamlEditUrl,
  configurationYaml,
} = createApiFuzzingConfigurationMutationResponse.data.createApiFuzzingCiConfiguration;

describe('EE - ApiFuzzingConfigurationSnippetModal', () => {
  let wrapper;

  const findModal = () => wrapper.find(GlModal);
  const findYamlSnippet = () => wrapper.findByTestId('api-fuzzing-modal-yaml-snippet');

  const createWrapper = (options) => {
    wrapper = extendedWrapper(
      shallowMount(
        ConfigurationSnippetModal,
        merge(
          {
            propsData: {
              ciYamlEditUrl: gitlabCiYamlEditUrl,
              yaml: configurationYaml,
            },
            attrs: {
              static: true,
              visible: true,
            },
          },
          options,
        ),
      ),
    );
  };

  beforeEach(() => {
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the YAML snippet', () => {
    expect(findYamlSnippet().text()).toBe(configurationYaml);
  });

  it('on primary event, text is copied to the clipbard and user is redirected to CI editor', async () => {
    findModal().vm.$emit('primary');

    expect(Clipboard).toHaveBeenCalledWith('#copy-yaml-snippet-and-edit-button', {
      text: expect.any(Function),
    });
    expect(redirectTo).toHaveBeenCalledWith(gitlabCiYamlEditUrl);
  });

  it('on secondary event, text is copied to the clipbard', async () => {
    findModal().vm.$emit('secondary');

    expect(Clipboard).toHaveBeenCalledWith('#copy-yaml-snippet-button', {
      text: expect.any(Function),
    });
  });
});
