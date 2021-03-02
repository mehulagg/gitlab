import { mount } from '@vue/test-utils';
import AxiosMockAdapter from 'axios-mock-adapter';
import AutoFixSettings from 'ee/security_configuration/components/auto_fix_settings.vue';
import { TEST_HOST } from 'helpers/test_constants';
import waitForPromises from 'helpers/wait_for_promises';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';

jest.mock('~/flash.js');

const AUTO_FIX_USER_PATH = `${TEST_HOST}/security_bot`;
const AUTO_FIX_HELP_PATH = `${TEST_HOST}/help/auto_fix`;
const CONTAINER_SCANNING_HELP_PATH = `${TEST_HOST}/help/container_scanning`;
const DEPENDENCY_SCANNING_HELP_PATH = `${TEST_HOST}/help/dependency_scanning`;
const TOGGLE_AUTO_FIX_ENDPOINT = 'auto_fix';

const AUTO_FIX_ENABLED_PROPS = {
  container_scanning: true,
  dependency_scanning: true,
};
const AUTO_FIX_DISABLED_PROPS = {
  container_scanning: false,
  dependency_scanning: false,
};

const FOOTER_TEXT =
  'Container Scanning and/or Dependency Scanning must be enabled. ' +
  'GitLab-Security-Bot will be the author of the auto-created merge request. More information.';

describe('Auto-fix Settings', () => {
  let axiosMock;
  let wrapper;

  const createComponent = (props = {}) => {
    axiosMock = new AxiosMockAdapter(axios);
    wrapper = mount(AutoFixSettings, {
      propsData: {
        autoFixHelpPath: AUTO_FIX_HELP_PATH,
        autoFixUserPath: AUTO_FIX_USER_PATH,
        containerScanningHelpPath: CONTAINER_SCANNING_HELP_PATH,
        dependencyScanningHelpPath: DEPENDENCY_SCANNING_HELP_PATH,
        toggleAutofixSettingEndpoint: TOGGLE_AUTO_FIX_ENDPOINT,
        canToggleAutoFixSettings: true,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    axiosMock.restore();
  });

  const findCheckbox = () => wrapper.find('input[type="checkbox"]');
  const findFooter = () => wrapper.find('footer');
  const findFooterLinks = () => findFooter().findAll('a');
  const getFooterTextContent = () => findFooter().text().trim();

  const expectCheckboxDisabled = () => expect(findCheckbox().attributes().disabled).toBeTruthy();

  const toggleCheckbox = () => findCheckbox().setChecked(!wrapper.vm.autoFixEnabledLocal);

  const expectCorrectLinks = () => {
    const links = findFooterLinks();
    expect(links.length).toBe(4);
    expect(links.at(0).attributes('href')).toBe(CONTAINER_SCANNING_HELP_PATH);
    expect(links.at(1).attributes('href')).toBe(DEPENDENCY_SCANNING_HELP_PATH);
    expect(links.at(2).attributes('href')).toBe(AUTO_FIX_USER_PATH);
    expect(links.at(3).attributes('href')).toBe(AUTO_FIX_HELP_PATH);
  };

  const itShowsEnabledInformation = () => {
    it('checkbox is checked', () => {
      expect(findCheckbox().element.checked).toBeTruthy();
    });

    it('explains how GitLab Security Bot will author auto-fix MRs', () => {
      expect(getFooterTextContent()).toBe(FOOTER_TEXT);
    });

    it('shows links to GitLab Security Bot profile and auto-fix documentation', () => {
      expectCorrectLinks();
    });
  };

  const itShowsDisabledInformation = () => {
    it('checkbox is unchecked', () => {
      expect(findCheckbox().element.checked).toBeFalsy();
    });

    it('explains how auto-fix will behave when enabled', () => {
      expect(getFooterTextContent()).toBe(FOOTER_TEXT);
    });

    it('shows links ', () => {
      expectCorrectLinks();
    });
  };

  const itSendsPostRequest = () => {
    it('sends a post request and sets loading state', () => {
      expect(axiosMock.history.post).toHaveLength(1);
      expectCheckboxDisabled();
    });
  };

  describe.each`
    description   | autoFixEnabled             | itShowsInitialState           | itShowsToggleSuccessState
    ${'enabled'}  | ${AUTO_FIX_ENABLED_PROPS}  | ${itShowsEnabledInformation}  | ${itShowsDisabledInformation}
    ${'disabled'} | ${AUTO_FIX_DISABLED_PROPS} | ${itShowsDisabledInformation} | ${itShowsEnabledInformation}
  `(
    'with auto-fix $description',
    ({ autoFixEnabled, itShowsInitialState, itShowsToggleSuccessState }) => {
      beforeEach(() => {
        createComponent({ autoFixEnabled });
      });

      itShowsInitialState();

      describe('when toggling the checkbox', () => {
        describe('on success', () => {
          beforeEach(() => {
            axiosMock.onPost(TOGGLE_AUTO_FIX_ENDPOINT).reply(200);
            toggleCheckbox();
          });

          itSendsPostRequest();

          describe('when request resolves', () => {
            beforeEach(waitForPromises);

            itShowsToggleSuccessState();

            it('resets loading state', () => {
              expect(findCheckbox().attributes().disabled).toBeFalsy();
            });
          });
        });

        describe('on error', () => {
          beforeEach(() => {
            axiosMock.onPost(TOGGLE_AUTO_FIX_ENDPOINT).reply(500);
            toggleCheckbox();
          });

          itSendsPostRequest();

          describe('when request resolves', () => {
            beforeEach(waitForPromises);

            itShowsInitialState();

            it('shows error flash', () => {
              expect(createFlash).toHaveBeenCalledWith({
                message:
                  'Something went wrong while toggling auto-fix settings, please try again later.',
              });
            });
          });
        });
      });
    },
  );

  describe("when user isn't allowed to toggle auto-fix settings", () => {
    beforeEach(() => {
      createComponent({
        canToggleAutoFixSettings: false,
        autoFixEnabled: AUTO_FIX_ENABLED_PROPS,
      });
    });

    it('disables the checkbox', () => {
      expectCheckboxDisabled();
    });
  });
});
