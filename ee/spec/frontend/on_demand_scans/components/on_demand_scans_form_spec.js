import { merge } from 'lodash';
import { mount, shallowMount } from '@vue/test-utils';
import { GlForm, GlSkeletonLoader } from '@gitlab/ui';
import { TEST_HOST } from 'helpers/test_constants';
import OnDemandScansForm from 'ee/on_demand_scans/components/on_demand_scans_form.vue';
import dastOnDemandScanCreate from 'ee/on_demand_scans/graphql/dast_on_demand_scan_create.mutation.graphql';
import { redirectTo } from '~/lib/utils/url_utility';

const helpPagePath = `${TEST_HOST}/application_security/dast/index#on-demand-scans`;
const projectPath = 'group/project';
const defaultBranch = 'master';
const scannerProfilesLibraryPath = '/security/configuration/dast_profiles#scanner-profiles';
const siteProfilesLibraryPath = '/security/configuration/dast_profiles#site-profiles';
const newScannerProfilePath = '/security/configuration/dast_profiles/dast_scanner_profile/new';
const newSiteProfilePath = `${TEST_HOST}/${projectPath}/-/security/configuration/dast_profiles`;

const defaultProps = {
  helpPagePath,
  projectPath,
  defaultBranch,
};

const scannerProfiles = [
  { id: 1, profileName: 'My first scanner profile', spiderTimeout: 5, targetTimeout: 10 },
  { id: 2, profileName: 'My second scanner profile', spiderTimeout: 20, targetTimeout: 150 },
];
const siteProfiles = [
  { id: 1, profileName: 'My first site profile', targetUrl: 'https://example.com' },
  { id: 2, profileName: 'My second site profile', targetUrl: 'https://foo.bar' },
];
const pipelineUrl = `${TEST_HOST}/${projectPath}/pipelines/123`;

jest.mock('~/lib/utils/url_utility', () => ({
  isAbsolute: jest.requireActual('~/lib/utils/url_utility').isAbsolute,
  redirectTo: jest.fn(),
}));

describe('OnDemandScansApp', () => {
  let wrapper;

  const findForm = () => wrapper.find(GlForm);
  const findByTestId = testId => wrapper.find(`[data-testid="${testId}"]`);
  const findScannerProfilesDropdown = () => findByTestId('scanner-profiles-dropdown');
  const findSiteProfilesDropdown = () => findByTestId('site-profiles-dropdown');
  const findManageScannerProfilesButton = () => findByTestId('manage-scanner-profiles-button');
  const findCreateNewScannerProfileLink = () => findByTestId('create-scanner-profile-link');
  const findManageSiteProfilesButton = () => findByTestId('manage-site-profiles-button');
  const findCreateNewSiteProfileLink = () => findByTestId('create-site-profile-link');
  const findAlert = () => findByTestId('on-demand-scan-error');
  const findCancelButton = () => findByTestId('on-demand-scan-cancel-button');
  const submitForm = () => findForm().vm.$emit('submit', { preventDefault: () => {} });

  const wrapperFactory = (mountFn = shallowMount) => (options = {}) => {
    wrapper = mountFn(
      OnDemandScansForm,
      merge(
        {},
        {
          propsData: defaultProps,
          mocks: {
            $apollo: {
              mutate: jest.fn(),
              queries: {
                scannerProfiles: {},
                siteProfiles: {},
              },
            },
          },
          provide: {
            glFeatures: { securityOnDemandScansScannerProfiles: true },
            scannerProfilesLibraryPath,
            siteProfilesLibraryPath,
            newScannerProfilePath,
            newSiteProfilePath,
          },
        },
        options,
        {
          data() {
            return { ...options.data };
          },
        },
      ),
    );
  };
  const createComponent = wrapperFactory();
  const createFullComponent = wrapperFactory(mount);

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders properly', () => {
    expect(wrapper.html()).not.toBe('');
  });

  describe('computed props', () => {
    describe('formData', () => {
      it('returns an object with a key:value mapping from the form object including the project path', () => {
        wrapper.vm.form = {
          siteProfileId: {
            value: siteProfiles[0],
            state: null,
            feedback: '',
          },
        };
        expect(wrapper.vm.formData).toEqual({
          fullPath: projectPath,
          siteProfileId: siteProfiles[0],
        });
      });
    });

    describe('formHasErrors', () => {
      it('returns true if any of the fields are invalid', () => {
        wrapper.vm.form = {
          siteProfileId: {
            value: siteProfiles[0],
            state: false,
            feedback: '',
          },
          foo: {
            value: 'bar',
            state: null,
          },
        };
        expect(wrapper.vm.formHasErrors).toBe(true);
      });

      it('returns false if none of the fields are invalid', () => {
        wrapper.vm.form = {
          siteProfileId: {
            value: siteProfiles[0],
            state: null,
            feedback: '',
          },
          foo: {
            value: 'bar',
            state: null,
          },
        };
        expect(wrapper.vm.formHasErrors).toBe(false);
      });
    });

    describe('someFieldEmpty', () => {
      it('returns true if any of the fields are empty', () => {
        wrapper.vm.form = {
          siteProfileId: {
            value: '',
            state: false,
            feedback: '',
          },
          foo: {
            value: 'bar',
            state: null,
          },
        };
        expect(wrapper.vm.someFieldEmpty).toBe(true);
      });

      it('returns false if no field is empty', () => {
        wrapper.vm.form = {
          siteProfileId: {
            value: siteProfiles[0],
            state: null,
            feedback: '',
          },
          foo: {
            value: 'bar',
            state: null,
          },
        };
        expect(wrapper.vm.someFieldEmpty).toBe(false);
      });
    });

    describe('isSubmitDisabled', () => {
      it.each`
        formHasErrors | someFieldEmpty | expected
        ${true}       | ${true}        | ${true}
        ${true}       | ${false}       | ${true}
        ${false}      | ${true}        | ${true}
        ${false}      | ${false}       | ${false}
      `(
        'is $expected when formHasErrors is $formHasErrors and someFieldEmpty is $someFieldEmpty',
        ({ formHasErrors, someFieldEmpty, expected }) => {
          createComponent({
            computed: {
              formHasErrors: () => formHasErrors,
              someFieldEmpty: () => someFieldEmpty,
            },
          });

          expect(wrapper.vm.isSubmitDisabled).toBe(expected);
        },
      );
    });
  });

  describe('scanner profiles with feature flag disabled', () => {
    beforeEach(() => {
      createComponent({
        provide: {
          glFeatures: { securityOnDemandScansScannerProfiles: false },
        },
      });
    });

    it('shows static scanner settings and no scanner profiles component', () => {
      expect(findScannerProfilesDropdown().exists()).toBe(false);
      expect(findManageScannerProfilesButton().exists()).toBe(false);
      expect(findCreateNewScannerProfileLink().exists()).toBe(false);
      expect(wrapper.text()).toContain('Passive');
      expect(wrapper.text()).toContain('master');
    });

    it('when submitting the form, GraphQL query does not include scanner data', async () => {
      wrapper.vm.siteProfiles = siteProfiles;
      await wrapper.vm.$nextTick();
      jest
        .spyOn(wrapper.vm.$apollo, 'mutate')
        .mockResolvedValue({ data: { dastOnDemandScanCreate: { pipelineUrl, errors: [] } } });
      findSiteProfilesDropdown().vm.$emit('input', siteProfiles[0]);
      submitForm();
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: dastOnDemandScanCreate,
        variables: {
          dastSiteProfileId: siteProfiles[0],
          fullPath: projectPath,
        },
      });
    });
  });

  describe.each`
    profileType  | manageProfilesButtonFinder         | manageProfilesPath            | createNewProfileButtonFinder       | newProfilePath           | dropdownFinder
    ${'scanner'} | ${findManageScannerProfilesButton} | ${scannerProfilesLibraryPath} | ${findCreateNewScannerProfileLink} | ${newScannerProfilePath} | ${findScannerProfilesDropdown}
    ${'site'}    | ${findManageSiteProfilesButton}    | ${siteProfilesLibraryPath}    | ${findCreateNewSiteProfileLink}    | ${newSiteProfilePath}    | ${findSiteProfilesDropdown}
  `(
    '$profileType profiles',
    ({
      profileType,
      manageProfilesButtonFinder,
      manageProfilesPath,
      createNewProfileButtonFinder,
      newProfilePath,
      dropdownFinder,
    }) => {
      describe('while profiles are being fetched', () => {
        beforeEach(() => {
          createComponent({
            mocks: { $apollo: { queries: { [`${profileType}Profiles`]: { loading: true } } } },
          });
        });

        it('shows a skeleton loader', () => {
          expect(wrapper.find(GlSkeletonLoader).exists()).toBe(true);
        });
      });

      describe('when profiles could not be fetched', () => {
        beforeEach(() => {
          createComponent();
          wrapper.vm.showErrors(`ERROR_FETCH_${profileType.toUpperCase()}_PROFILES`);
        });

        it('shows a non-dismissible alert and no field', () => {
          const alert = findAlert();
          expect(alert.exists()).toBe(true);
          expect(alert.props('dismissible')).toBe(false);
          expect(alert.text()).toContain(
            `Could not fetch ${profileType} profiles. Please refresh the page, or try again later.`,
          );
        });
      });

      describe('when there are no profiles yet', () => {
        beforeEach(() => {
          createFullComponent();
        });

        it('disables the link to profiles library', () => {
          expect(manageProfilesButtonFinder().props('disabled')).toBe(true);
        });

        it('shows a link to create a new profile', () => {
          const link = createNewProfileButtonFinder();
          expect(link.exists()).toBe(true);
          expect(link.attributes('href')).toBe(newProfilePath);
        });
      });

      describe('when there are profiles', () => {
        beforeEach(() => {
          createFullComponent({
            data: {
              scannerProfiles,
              siteProfiles,
              form: {
                dastScannerProfileId: { value: scannerProfiles[0].id },
                dastSiteProfileId: { value: siteProfiles[0].id },
              },
            },
          });
        });

        it('enables link to profiles management', () => {
          expect(manageProfilesButtonFinder().props('disabled')).toBe(false);
          expect(manageProfilesButtonFinder().attributes('href')).toBe(manageProfilesPath);
        });

        it('shows a dropdown containing the profiles', () => {
          const dropdown = dropdownFinder();
          expect(dropdown.exists()).toBe(true);
          expect(dropdown.element.children).toHaveLength(siteProfiles.length);
        });

        it('when a profile is selected, its summary is displayed below the dropdow', () => {
          const summary = wrapper.find(`[data-testid="${profileType}-profile-summary"]`);

          expect(summary.exists()).toBe(true);
        });
      });
    },
  );

  describe('submission', () => {
    beforeEach(() => {
      createComponent({
        data: {
          scannerProfiles,
          siteProfiles,
        },
      });
    });

    describe('on success', () => {
      beforeEach(() => {
        jest
          .spyOn(wrapper.vm.$apollo, 'mutate')
          .mockResolvedValue({ data: { dastOnDemandScanCreate: { pipelineUrl, errors: [] } } });
        findScannerProfilesDropdown().vm.$emit('input', scannerProfiles[0].id);
        findSiteProfilesDropdown().vm.$emit('input', siteProfiles[0]);
        submitForm();
      });

      it('sets loading state', () => {
        expect(wrapper.vm.loading).toBe(true);
      });

      it('triggers GraphQL mutation', () => {
        expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
          mutation: dastOnDemandScanCreate,
          variables: {
            dastScannerProfileId: scannerProfiles[0].id,
            dastSiteProfileId: siteProfiles[0],
            fullPath: projectPath,
          },
        });
      });

      it('redirects to the URL provided in the response', () => {
        expect(redirectTo).toHaveBeenCalledWith(pipelineUrl);
      });

      it('does not show an alert', () => {
        expect(findAlert().exists()).toBe(false);
      });
    });

    describe('on top-level error', () => {
      beforeEach(() => {
        jest.spyOn(wrapper.vm.$apollo, 'mutate').mockRejectedValue();
        findScannerProfilesDropdown().vm.$emit('input', scannerProfiles[0].id);
        findSiteProfilesDropdown().vm.$emit('input', siteProfiles[0]);
        submitForm();
      });

      it('resets loading state', () => {
        expect(wrapper.vm.loading).toBe(false);
      });

      it('shows an alert', () => {
        const alert = findAlert();
        expect(alert.exists()).toBe(true);
        expect(alert.text()).toContain('Could not run the scan. Please try again.');
      });
    });

    describe('on errors as data', () => {
      const errors = ['error#1', 'error#2', 'error#3'];

      beforeEach(() => {
        jest
          .spyOn(wrapper.vm.$apollo, 'mutate')
          .mockResolvedValue({ data: { dastOnDemandScanCreate: { pipelineUrl: null, errors } } });
        findScannerProfilesDropdown().vm.$emit('input', scannerProfiles[0].id);
        findSiteProfilesDropdown().vm.$emit('input', siteProfiles[0]);
        submitForm();
      });

      it('resets loading state', () => {
        expect(wrapper.vm.loading).toBe(false);
      });

      it('shows an alert with the returned errors', () => {
        const alert = findAlert();

        expect(alert.exists()).toBe(true);
        errors.forEach(error => {
          expect(alert.text()).toContain(error);
        });
      });
    });
  });

  describe('cancel', () => {
    it('emits cancel event on click', () => {
      jest.spyOn(wrapper.vm, '$emit');
      findCancelButton().vm.$emit('click');

      expect(wrapper.vm.$emit).toHaveBeenCalledWith('cancel');
    });
  });
});
