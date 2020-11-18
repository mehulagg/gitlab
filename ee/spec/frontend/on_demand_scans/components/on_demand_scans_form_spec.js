import { GlForm, GlSkeletonLoader } from '@gitlab/ui';
import { shallowMount, mount } from '@vue/test-utils';
import { merge } from 'lodash';
import OnDemandScansForm from 'ee/on_demand_scans/components/on_demand_scans_form.vue';
import OnDemandScansScannerProfileSelector from 'ee/on_demand_scans/components/profile_selector/scanner_profile_selector.vue';
import OnDemandScansSiteProfileSelector from 'ee/on_demand_scans/components/profile_selector/site_profile_selector.vue';
import dastOnDemandScanCreate from 'ee/on_demand_scans/graphql/dast_on_demand_scan_create.mutation.graphql';
import { redirectTo } from '~/lib/utils/url_utility';
import { scannerProfiles, siteProfiles } from '../mock_data';

const helpPagePath = '/application_security/dast/index#on-demand-scans';
const projectPath = 'group/project';
const defaultBranch = 'master';
const scannerProfilesLibraryPath = '/security/configuration/dast_profiles#scanner-profiles';
const siteProfilesLibraryPath = '/security/configuration/dast_profiles#site-profiles';
const newScannerProfilePath = '/security/configuration/dast_profiles/dast_scanner_profile/new';
const newSiteProfilePath = `/${projectPath}/-/security/configuration/dast_profiles`;

const defaultProps = {
  helpPagePath,
  projectPath,
  defaultBranch,
};

const defaultMocks = {
  $apollo: {
    mutate: jest.fn(),
    queries: {
      scannerProfiles: {},
      siteProfiles: {},
    },
    addSmartQuery: jest.fn(),
  },
};

const pipelineUrl = `/${projectPath}/pipelines/123`;

jest.mock('~/lib/utils/url_utility', () => ({
  isAbsolute: jest.requireActual('~/lib/utils/url_utility').isAbsolute,
  redirectTo: jest.fn(),
}));

describe('OnDemandScansForm', () => {
  let subject;

  const findForm = () => subject.find(GlForm);
  const findByTestId = testId => subject.find(`[data-testid="${testId}"]`);
  const findAlert = () => findByTestId('on-demand-scan-error');
  const findSubmitButton = () => findByTestId('on-demand-scan-submit-button');
  const findCancelButton = () => findByTestId('on-demand-scan-cancel-button');

  const setFormData = () => {
    subject.find(OnDemandScansScannerProfileSelector).vm.$emit('input', scannerProfiles[0].id);
    subject.find(OnDemandScansSiteProfileSelector).vm.$emit('input', siteProfiles[0].id);
    return subject.vm.$nextTick();
  };
  const submitForm = () => findForm().vm.$emit('submit', { preventDefault: () => {} });

  const subjectMounterFactory = (mountFn = shallowMount) => (options = {}) => {
    subject = mountFn(
      OnDemandScansForm,
      merge(
        {},
        {
          propsData: defaultProps,
          mocks: defaultMocks,
          provide: {
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
  const mountSubject = subjectMounterFactory(mount);
  const mountShallowSubject = subjectMounterFactory();

  afterEach(() => {
    subject.destroy();
    subject = null;
  });

  it('renders properly', () => {
    mountSubject();
    expect(subject.html()).not.toBe('');
  });

  it.each`
    scannerProfilesLoading | siteProfilesLoading | isLoading
    ${true}                | ${true}             | ${true}
    ${false}               | ${true}             | ${true}
    ${true}                | ${false}            | ${true}
    ${false}               | ${false}            | ${false}
  `(
    'sets loading state to $isLoading if scanner profiles loading is $scannerProfilesLoading and site profiles loading is $siteProfilesLoading',
    ({ scannerProfilesLoading, siteProfilesLoading, isLoading }) => {
      mountShallowSubject({
        mocks: {
          $apollo: {
            queries: {
              scannerProfiles: { loading: scannerProfilesLoading },
              siteProfiles: { loading: siteProfilesLoading },
            },
          },
        },
      });

      expect(subject.find(GlSkeletonLoader).exists()).toBe(isLoading);
    },
  );

  describe('submit button', () => {
    let submitButton;

    beforeEach(() => {
      mountShallowSubject({
        data: {
          scannerProfiles,
          siteProfiles,
        },
      });
      submitButton = findSubmitButton();
    });

    it('is disabled while some fields are empty', () => {
      expect(submitButton.props('disabled')).toBe(true);
    });

    it('becomes enabled when form is valid', async () => {
      await setFormData();

      expect(submitButton.props('disabled')).toBe(false);
    });
  });

  describe('submission', () => {
    beforeEach(() => {
      mountShallowSubject({
        data: {
          scannerProfiles,
          siteProfiles,
        },
      });
    });

    describe('on success', () => {
      beforeEach(async () => {
        jest
          .spyOn(subject.vm.$apollo, 'mutate')
          .mockResolvedValue({ data: { dastOnDemandScanCreate: { pipelineUrl, errors: [] } } });
        await setFormData();
        submitForm();
      });

      it('sets loading state', () => {
        expect(subject.vm.loading).toBe(true);
      });

      it('triggers GraphQL mutation', () => {
        expect(subject.vm.$apollo.mutate).toHaveBeenCalledWith({
          mutation: dastOnDemandScanCreate,
          variables: {
            dastScannerProfileId: scannerProfiles[0].id,
            dastSiteProfileId: siteProfiles[0].id,
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
      beforeEach(async () => {
        jest.spyOn(subject.vm.$apollo, 'mutate').mockRejectedValue();
        await setFormData();
        submitForm();
      });

      it('resets loading state', () => {
        expect(subject.vm.loading).toBe(false);
      });

      it('shows an alert', () => {
        const alert = findAlert();
        expect(alert.exists()).toBe(true);
        expect(alert.text()).toContain('Could not run the scan. Please try again.');
      });
    });

    describe('on errors as data', () => {
      const errors = ['error#1', 'error#2', 'error#3'];

      beforeEach(async () => {
        jest
          .spyOn(subject.vm.$apollo, 'mutate')
          .mockResolvedValue({ data: { dastOnDemandScanCreate: { pipelineUrl: null, errors } } });
        await setFormData();
        submitForm();
      });

      it('resets loading state', () => {
        expect(subject.vm.loading).toBe(false);
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
      mountShallowSubject();
      jest.spyOn(subject.vm, '$emit');
      findCancelButton().vm.$emit('click');

      expect(subject.vm.$emit).toHaveBeenCalledWith('cancel');
    });
  });
});
