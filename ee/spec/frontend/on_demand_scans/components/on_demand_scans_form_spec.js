import { GlForm, GlSkeletonLoader } from '@gitlab/ui';
import { shallowMount, mount, createLocalVue } from '@vue/test-utils';
import { merge } from 'lodash';
import VueApollo from 'vue-apollo';
import createApolloProvider from 'helpers/mock_apollo_helper';
import OnDemandScansForm from 'ee/on_demand_scans/components/on_demand_scans_form.vue';
import ScannerProfileSelector from 'ee/on_demand_scans/components/profile_selector/scanner_profile_selector.vue';
import SiteProfileSelector from 'ee/on_demand_scans/components/profile_selector/site_profile_selector.vue';
import dastOnDemandScanCreate from 'ee/on_demand_scans/graphql/dast_on_demand_scan_create.mutation.graphql';
import dastScannerProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_scanner_profiles.query.graphql';
import dastSiteProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_site_profiles.query.graphql';
import * as responses from '../mocks/apollo_mocks';
import { scannerProfiles, siteProfiles } from '../mocks/mock_data';
import { redirectTo } from '~/lib/utils/url_utility';

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

const pipelineUrl = `/${projectPath}/pipelines/123`;
const [passiveScannerProfile, activeScannerProfile] = scannerProfiles;
const [nonValidatedSiteProfile, validatedSiteProfile] = siteProfiles;

jest.mock('~/lib/utils/url_utility', () => ({
  isAbsolute: jest.requireActual('~/lib/utils/url_utility').isAbsolute,
  redirectTo: jest.fn(),
}));

describe('OnDemandScansForm', () => {
  let localVue;
  let subject;
  let requestHandlers;

  const findForm = () => subject.find(GlForm);
  const findByTestId = testId => subject.find(`[data-testid="${testId}"]`);
  const findAlert = () => findByTestId('on-demand-scan-error');
  const findProfilesConflictAlert = () => findByTestId('on-demand-scans-profiles-conflict-alert');
  const findSubmitButton = () => findByTestId('on-demand-scan-submit-button');

  const setValidFormData = () => {
    subject.find(ScannerProfileSelector).vm.$emit('input', passiveScannerProfile.id);
    subject.find(SiteProfileSelector).vm.$emit('input', nonValidatedSiteProfile.id);
    return subject.vm.$nextTick();
  };
  const submitForm = () => findForm().vm.$emit('submit', { preventDefault: () => {} });

  const createMockApolloProvider = handlers => {
    localVue.use(VueApollo);

    requestHandlers = {
      dastScannerProfiles: jest.fn().mockResolvedValue(responses.dastScannerProfiles()),
      dastSiteProfiles: jest.fn().mockResolvedValue(responses.dastSiteProfiles()),
      ...handlers,
    };

    return createApolloProvider([
      [dastScannerProfilesQuery, requestHandlers.dastScannerProfiles],
      [dastSiteProfilesQuery, requestHandlers.dastSiteProfiles],
    ]);
  };

  const subjectMounterFactory = (mountFn = shallowMount) => (options = {}, withHandlers) => {
    localVue = createLocalVue();
    let defaultMocks = {
      $apollo: {
        mutate: jest.fn(),
        queries: {
          scannerProfiles: {},
          siteProfiles: {},
        },
        addSmartQuery: jest.fn(),
      },
    };
    let apolloProvider;
    if (withHandlers) {
      apolloProvider = createMockApolloProvider(withHandlers);
      defaultMocks = {};
    }
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
            glFeatures: {
              securityOnDemandScansSiteValidation: true,
            },
          },
        },
        { ...options, localVue, apolloProvider },
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
      await setValidFormData();

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
        await setValidFormData();
        submitForm();
      });

      it('sets loading state', () => {
        expect(subject.vm.loading).toBe(true);
      });

      it('triggers GraphQL mutation', () => {
        expect(subject.vm.$apollo.mutate).toHaveBeenCalledWith({
          mutation: dastOnDemandScanCreate,
          variables: {
            dastScannerProfileId: passiveScannerProfile.id,
            dastSiteProfileId: nonValidatedSiteProfile.id,
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
        await setValidFormData();
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
        await setValidFormData();
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

  describe.each`
    description                                  | selectedScannerProfile   | selectedSiteProfile        | hasConflict
    ${'a passive scan and a non-validated site'} | ${passiveScannerProfile} | ${nonValidatedSiteProfile} | ${false}
    ${'a passive scan and a validated site'}     | ${passiveScannerProfile} | ${validatedSiteProfile}    | ${false}
    ${'an active scan and a non-validated site'} | ${activeScannerProfile}  | ${nonValidatedSiteProfile} | ${true}
    ${'an active scan and a validated site'}     | ${activeScannerProfile}  | ${validatedSiteProfile}    | ${false}
  `(
    'profiles conflict prevention',
    ({ description, selectedScannerProfile, selectedSiteProfile, hasConflict }) => {
      const setFormData = () => {
        subject.find(ScannerProfileSelector).vm.$emit('input', selectedScannerProfile.id);
        subject.find(SiteProfileSelector).vm.$emit('input', selectedSiteProfile.id);
        return subject.vm.$nextTick();
      };

      it(
        hasConflict
          ? `warns about conflicting profiles when user selects ${description}`
          : `does not report any conflict when user selects ${description}`,
        async () => {
          mountShallowSubject({
            data: {
              scannerProfiles,
              siteProfiles,
            },
          });
          await setFormData();

          expect(findProfilesConflictAlert().exists()).toBe(hasConflict);
          expect(findSubmitButton().props('disabled')).toBe(hasConflict);
        },
      );

      describe('feature flag disabled', () => {
        beforeEach(() => {
          mountShallowSubject({
            provide: {
              glFeatures: {
                securityOnDemandScansSiteValidation: false,
              },
            },
            data: {
              scannerProfiles,
              siteProfiles,
            },
          });
          return setFormData();
        });

        it(`does not report any conflict when user selects ${description}`, () => {
          expect(findProfilesConflictAlert().exists()).toBe(false);
          expect(findSubmitButton().props('disabled')).toBe(false);
        });
      });
    },
  );

  describe.each`
    profileType  | query                    | selector                  | profiles
    ${'scanner'} | ${'dastScannerProfiles'} | ${ScannerProfileSelector} | ${scannerProfiles}
    ${'site'}    | ${'dastSiteProfiles'}    | ${SiteProfileSelector}    | ${siteProfiles}
  `('when there is a single $profileType profile', ({ query, selector, profiles }) => {
    const [profile] = profiles;

    beforeEach(() => {
      mountShallowSubject(
        {},
        {
          [query]: jest.fn().mockResolvedValue(responses[query]([profile])),
        },
      );
    });

    it('automatically selects the only available profile', () => {
      expect(subject.find(selector).attributes('value')).toBe(profile.id);
    });
  });
});
