import { GlAlert, GlForm, GlModal } from '@gitlab/ui';
import { within } from '@testing-library/dom';
import { mount, shallowMount } from '@vue/test-utils';
import merge from 'lodash/merge';
import DastScannerProfileForm from 'ee/security_configuration/dast_scanner_profiles/components/dast_scanner_profile_form.vue';
import { SCAN_TYPE } from 'ee/security_configuration/dast_scanner_profiles/constants';
import dastScannerProfileCreateMutation from 'ee/security_configuration/dast_scanner_profiles/graphql/dast_scanner_profile_create.mutation.graphql';
import dastScannerProfileUpdateMutation from 'ee/security_configuration/dast_scanner_profiles/graphql/dast_scanner_profile_update.mutation.graphql';
import { scannerProfiles } from 'ee_jest/on_demand_scans/mocks/mock_data';
import { TEST_HOST } from 'helpers/test_constants';
import { redirectTo } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility', () => ({
  redirectTo: jest.fn(),
}));

const projectFullPath = 'group/project';
const profilesLibraryPath = `${TEST_HOST}/${projectFullPath}/-/security/configuration/dast_profiles`;
const onDemandScansPath = `${TEST_HOST}/${projectFullPath}/-/on_demand_scans`;
const defaultProfile = scannerProfiles[0];

const {
  profileName,
  spiderTimeout,
  targetTimeout,
  scanType,
  useAjaxSpider,
  showDebugMessages,
} = defaultProfile;

const defaultProps = {
  profilesLibraryPath,
  projectFullPath,
  onDemandScansPath,
};

describe('DAST Scanner Profile', () => {
  let wrapper;

  const withinComponent = () => within(wrapper.element);
  const findByTestId = (testId) => wrapper.find(`[data-testid="${testId}"`);

  const findForm = () => wrapper.find(GlForm);
  const findProfileNameInput = () => findByTestId('profile-name-input');
  const findSpiderTimeoutInput = () => findByTestId('spider-timeout-input');
  const findTargetTimeoutInput = () => findByTestId('target-timeout-input');
  const findSubmitButton = () => findByTestId('dast-scanner-profile-form-submit-button');
  const findCancelButton = () => findByTestId('dast-scanner-profile-form-cancel-button');
  const findScanType = () => findByTestId('scan-type-option');

  const findCancelModal = () => wrapper.find(GlModal);
  const findAlert = () => wrapper.find(GlAlert);
  const submitForm = () => findForm().vm.$emit('submit', { preventDefault: () => {} });

  const componentFactory = (mountFn = shallowMount) => (options) => {
    wrapper = mountFn(
      DastScannerProfileForm,
      merge(
        {},
        {
          propsData: defaultProps,
          mocks: {
            $apollo: {
              mutate: jest.fn(),
            },
          },
        },
        options,
      ),
    );
  };
  const createComponent = componentFactory();
  const createFullComponent = componentFactory(mount);

  afterEach(() => {
    wrapper.destroy();
  });

  it('form renders properly', () => {
    createComponent();
    expect(findForm().exists()).toBe(true);
  });

  describe('submit button', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('is disabled if', () => {
      it('form contains errors', async () => {
        findProfileNameInput().vm.$emit('input', profileName);
        await findSpiderTimeoutInput().vm.$emit('input', '12312');
        expect(findSubmitButton().props('disabled')).toBe(true);
      });

      it('at least one field is empty', async () => {
        findProfileNameInput().vm.$emit('input', '');
        await findSpiderTimeoutInput().vm.$emit('input', spiderTimeout);
        await findTargetTimeoutInput().vm.$emit('input', targetTimeout);
        expect(findSubmitButton().props('disabled')).toBe(true);
      });
    });

    describe('is enabled if', () => {
      it('all fields are filled in and valid', async () => {
        findProfileNameInput().vm.$emit('input', profileName);
        await findSpiderTimeoutInput().vm.$emit('input', 0);
        await findTargetTimeoutInput().vm.$emit('input', targetTimeout);
        expect(findSubmitButton().props('disabled')).toBe(false);
      });
    });
  });

  describe.each`
    timeoutType | finder                    | invalidValues | validValue
    ${'Spider'} | ${findSpiderTimeoutInput} | ${[-1, 2881]} | ${spiderTimeout}
    ${'Target'} | ${findTargetTimeoutInput} | ${[0, 3601]}  | ${targetTimeout}
  `('$timeoutType Timeout', ({ finder, invalidValues, validValue }) => {
    const errorMessage = 'Please enter a valid timeout value';

    beforeEach(() => {
      createFullComponent();
    });

    it.each(invalidValues)('is marked as invalid provided an invalid value', async (value) => {
      await finder().find('input').setValue(value);

      expect(wrapper.text()).toContain(errorMessage);
    });

    it('is marked as valid provided a valid value', async () => {
      await finder().find('input').setValue(validValue);

      expect(wrapper.text()).not.toContain(errorMessage);
    });

    it('should allow only numbers', async () => {
      expect(finder().find('input').props('type')).toBe('number');
    });
  });

  describe.each`
    title                     | profile           | mutation                            | mutationVars                 | mutationKind
    ${'New scanner profile'}  | ${{}}             | ${dastScannerProfileCreateMutation} | ${{}}                        | ${'dastScannerProfileCreate'}
    ${'Edit scanner profile'} | ${defaultProfile} | ${dastScannerProfileUpdateMutation} | ${{ id: defaultProfile.id }} | ${'dastScannerProfileUpdate'}
  `('$title', ({ profile, title, mutation, mutationVars, mutationKind }) => {
    beforeEach(() => {
      createFullComponent({
        propsData: {
          profile,
        },
      });
    });

    it('sets the correct title', () => {
      expect(withinComponent().getByRole('heading', { name: title })).not.toBeNull();
    });

    it('populates the fields with the data passed in via the profile prop or default values', () => {
      expect(findProfileNameInput().element.value).toBe(profile?.name ?? '');
      expect(findScanType().vm.$attrs.checked).toBe(profile?.scanType ?? SCAN_TYPE.PASSIVE);
    });

    describe('submission', () => {
      const createdProfileId = 30203;

      describe('on success', () => {
        beforeEach(() => {
          jest
            .spyOn(wrapper.vm.$apollo, 'mutate')
            .mockResolvedValue({ data: { [mutationKind]: { id: createdProfileId } } });
          findProfileNameInput().vm.$emit('input', profileName);
          findSpiderTimeoutInput().vm.$emit('input', spiderTimeout);
          findTargetTimeoutInput().vm.$emit('input', targetTimeout);
          submitForm();
        });

        it('sets loading state', () => {
          expect(findSubmitButton().props('loading')).toBe(true);
        });

        it('triggers GraphQL mutation', () => {
          expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
            mutation,
            variables: {
              input: {
                profileName,
                spiderTimeout,
                targetTimeout,
                fullPath: projectFullPath,
                scanType,
                useAjaxSpider,
                showDebugMessages,
                ...mutationVars,
              },
            },
          });
        });

        it('redirects to the profiles library', () => {
          expect(redirectTo).toHaveBeenCalledWith(profilesLibraryPath);
        });

        it('does not show an alert', () => {
          expect(findAlert().exists()).toBe(false);
        });
      });

      describe('on top-level error', () => {
        beforeEach(() => {
          createComponent();
          jest.spyOn(wrapper.vm.$apollo, 'mutate').mockRejectedValue();
          const input = findTargetTimeoutInput();
          input.vm.$emit('input', targetTimeout);
          submitForm();
        });

        it('resets loading state', () => {
          expect(findSubmitButton().props('loading')).toBe(false);
        });

        it('shows an error alert', () => {
          expect(findAlert().exists()).toBe(true);
        });
      });

      describe('on errors as data', () => {
        const errors = ['Name is already taken', 'Value should be Int', 'error#3'];

        beforeEach(() => {
          jest
            .spyOn(wrapper.vm.$apollo, 'mutate')
            .mockResolvedValue({ data: { [mutationKind]: { errors } } });
          const input = findSpiderTimeoutInput();
          input.vm.$emit('input', spiderTimeout);
          submitForm();
        });

        it('resets loading state', () => {
          expect(findSubmitButton().props('loading')).toBe(false);
        });

        it('shows an alert with the returned errors', () => {
          const alert = findAlert();

          expect(alert.exists()).toBe(true);
          errors.forEach((error) => {
            expect(alert.text()).toContain(error);
          });
        });
      });
    });

    describe('cancellation', () => {
      beforeEach(() => {
        createFullComponent();
      });

      describe('form empty', () => {
        it('redirects to the profiles library', () => {
          findCancelButton().vm.$emit('click');
          expect(redirectTo).toHaveBeenCalledWith(profilesLibraryPath);
        });
      });

      describe('form not empty', () => {
        beforeEach(() => {
          findProfileNameInput().setValue(profileName);
        });

        it('asks the user to confirm the action', () => {
          jest.spyOn(findCancelModal().vm, 'show').mockReturnValue();
          findCancelButton().trigger('click');
          expect(findCancelModal().vm.show).toHaveBeenCalled();
        });

        it('redirects to the profiles library if confirmed', () => {
          findCancelModal().vm.$emit('ok');
          expect(redirectTo).toHaveBeenCalledWith(profilesLibraryPath);
        });
      });
    });
  });
});
