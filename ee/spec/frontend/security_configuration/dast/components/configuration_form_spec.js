import { GlSprintf } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import ConfigurationSnippetModal from 'ee/security_configuration/components/configuration_snippet_modal.vue';
import { CONFIGURATION_SNIPPET_MODAL_ID } from 'ee/security_configuration/components/constants';
import ConfigurationForm from 'ee/security_configuration/dast/components/configuration_form.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { CODE_SNIPPET_SOURCE_DAST } from '~/pipeline_editor/components/code_snippet_alert/constants';
import { DAST_HELP_PATH } from '~/security_configuration/components/constants';

const securityConfigurationPath = '/security/configuration';
const gitlabCiYamlEditPath = '/ci/editor';
const template = `# Add \`dast\` to your \`stages:\` configuration
stages:
  - dast

# Include the DAST template
include:
  - template: DAST.gitlab-ci.yml

# Your selected site and scanner profiles:
dast:
  stage: dast
  dast_configuration:
    site_profile: "My DAST Site Profile"
    scanner_profile: "My DAST Scanner Profile"
`;

describe('EE - DAST Configuration Form', () => {
  let wrapper;

  const findCancelButton = () => wrapper.findByTestId('dast-configuration-cancel-button');
  const findConfigurationSnippetModal = () => wrapper.findComponent(ConfigurationSnippetModal);

  const createComponent = () => {
    wrapper = extendedWrapper(
      mount(ConfigurationForm, {
        provide: {
          securityConfigurationPath,
          gitlabCiYamlEditPath,
        },
        stubs: {
          GlSprintf,
        },
      }),
    );
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

  describe('form', () => {
    it('submit button should open the model with correct props', () => {
      jest.spyOn(wrapper.vm.$refs[CONFIGURATION_SNIPPET_MODAL_ID], 'show');

      wrapper.find('form').trigger('submit');

      expect(wrapper.vm.$refs[CONFIGURATION_SNIPPET_MODAL_ID].show).toHaveBeenCalled();

      expect(findConfigurationSnippetModal().props()).toEqual({
        ciYamlEditUrl: gitlabCiYamlEditPath,
        yaml: template,
        redirectParam: CODE_SNIPPET_SOURCE_DAST,
        scanType: 'DAST',
      });
    });

    it('cancel button points to Security Configuration page', () => {
      expect(findCancelButton().attributes('href')).toBe('/security/configuration');
    });
  });
});
