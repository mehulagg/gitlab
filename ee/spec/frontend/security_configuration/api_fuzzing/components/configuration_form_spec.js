import { mount } from '@vue/test-utils';
import { merge } from 'lodash';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { SCAN_MODES } from 'ee/security_configuration/api_fuzzing/constants';
import ConfigurationForm from 'ee/security_configuration/api_fuzzing/components/configuration_form.vue';
import FormInput from 'ee/security_configuration/components/form_input.vue';
import DropdownInput from 'ee/security_configuration/components/dropdown_input.vue';

const makeScanProfile = (name) => ({
  name,
  description: `${name} description`,
  yaml: `
  ---
  :Name: ${name}
  `.trim(),
});

describe('EE - ApiFuzzingConfigurationForm', () => {
  let wrapper;

  const apiFuzzingCiConfiguration = {
    scanModes: Object.keys(SCAN_MODES),
    scanProfiles: [makeScanProfile('Quick-10'), makeScanProfile('Medium-20')],
  };

  const findEnableAuthenticationCheckbox = () =>
    wrapper.findByTestId('api-fuzzing-enable-authentication-checkbox');
  const findScanScanModeInput = () => wrapper.findAll(DropdownInput).at(0);
  const findSpecificationFileInput = () => wrapper.findAll(FormInput).at(1);
  const findAuthenticationNotice = () => wrapper.findByTestId('api-fuzzing-authentication-notice');
  const findScanProfileDropdownInput = () => wrapper.findAll(DropdownInput).at(1);
  const findScanProfileYamlViewer = () =>
    wrapper.findByTestId('api-fuzzing-scan-profile-yaml-viewer');

  const createWrapper = (options = {}) => {
    wrapper = extendedWrapper(
      mount(
        ConfigurationForm,
        merge(
          {
            provide: {
              apiFuzzingAuthenticationDocumentationPath:
                'api_fuzzing_authentication/documentation/path',
              ciVariablesDocumentationPath: '/ci_cd_variables/documentation/path',
              projectCiSettingsPath: '/project/settings/ci_cd',
              canSetProjectCiVariables: true,
            },
            propsData: {
              apiFuzzingCiConfiguration,
            },
          },
          options,
        ),
      ),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('includes a link to API fuzzing authentication documentation', () => {
    createWrapper();

    expect(wrapper.html()).toContain('api_fuzzing_authentication/documentation/path');
  });

  describe('scan modes', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('displays a dropdown option for each scan mode', () => {
      findScanScanModeInput()
        .findAll('li')
        .wrappers.forEach((item, index) => {
          expect(item.text()).toBe(
            SCAN_MODES[apiFuzzingCiConfiguration.scanModes[index]].scanModeLabel,
          );
        });
    });

    it('by default, the specification file input is hidden', () => {
      expect(wrapper.findAll(FormInput)).toHaveLength(1);
    });

    describe.each(Object.keys(SCAN_MODES))('when %s scan mode is selected', (scanMode) => {
      it('the specificationfile input becomes visible and has the correct labels', async () => {
        const selectedScanMode = SCAN_MODES[scanMode];
        findScanScanModeInput().vm.$emit('input', scanMode);
        await wrapper.vm.$nextTick();

        const specificationFileInput = findSpecificationFileInput();
        expect(specificationFileInput.exists()).toBe(true);
        expect(specificationFileInput.text()).toContain(selectedScanMode.label);
        expect(specificationFileInput.text()).toContain(selectedScanMode.description);
        expect(specificationFileInput.find('input').attributes('placeholder')).toBe(
          selectedScanMode.placeholder,
        );
      });
    });
  });

  describe('authentication', () => {
    it('authentication section is hidden by default', () => {
      createWrapper();

      expect(findAuthenticationNotice().exists()).toBe(false);
    });

    it('authentication section becomes visible once checkbox is checked', async () => {
      createWrapper();
      await findEnableAuthenticationCheckbox().trigger('click');

      expect(findAuthenticationNotice().exists()).toBe(true);
    });

    it('sees the the proper notice as a maintainer', async () => {
      createWrapper();
      await findEnableAuthenticationCheckbox().trigger('click');

      expect(findAuthenticationNotice().text()).toMatchInterpolatedText(
        'Make sure your credentials are secured To prevent a security leak, authentication info must be added as a CI variable. As a user with maintainer access rights, you can manage CI variables in the Settings area.',
      );
    });

    it('sees the the proper notice as a developer', async () => {
      createWrapper({
        provide: {
          canSetProjectCiVariables: false,
        },
      });
      await findEnableAuthenticationCheckbox().trigger('click');

      expect(findAuthenticationNotice().text()).toMatchInterpolatedText(
        "You may need a maintainer's help to secure your credentials. To prevent a security leak, authentication info must be added as a CI variable. A user with maintainer access rights can manage CI variables in the Settings area. We detected that you are not a maintainer. Commit your changes and assign them to a maintainer to update the credentials before merging.",
      );
    });
  });

  describe('scan profiles', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('displays a dropdown option for each scan profile', () => {
      findScanProfileDropdownInput()
        .findAll('li')
        .wrappers.forEach((item, index) => {
          expect(item.text()).toBe(apiFuzzingCiConfiguration.scanProfiles[index].description);
        });
    });

    it('by default, YAML viewer is not visible', () => {
      expect(findScanProfileYamlViewer().exists()).toBe(false);
    });

    it('when a scan profile is selected, its YAML is visible', async () => {
      const selectedScanProfile = apiFuzzingCiConfiguration.scanProfiles[0];
      wrapper.findAll(DropdownInput).at(1).vm.$emit('input', selectedScanProfile.name);
      await wrapper.vm.$nextTick();

      expect(findScanProfileYamlViewer().exists()).toBe(true);
      expect(findScanProfileYamlViewer().text()).toBe(selectedScanProfile.yaml);
    });
  });
});
