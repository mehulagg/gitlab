import { GlForm, GlFormInput, GlSkeletonLoader } from '@gitlab/ui';
import { shallowMount, mount, createLocalVue } from '@vue/test-utils';
import { merge } from 'lodash';
import VueApollo from 'vue-apollo';
import createApolloProvider from 'helpers/mock_apollo_helper';
import OnDemandScansForm from 'ee/on_demand_scans/components/on_demand_scans_form.vue';
import ScannerProfileSelector from 'ee/on_demand_scans/components/profile_selector/scanner_profile_selector.vue';
import SiteProfileSelector from 'ee/on_demand_scans/components/profile_selector/site_profile_selector.vue';
import dastScanCreateMutation from 'ee/on_demand_scans/graphql/dast_scan_create.mutation.graphql';
import dastScanUpdateMutation from 'ee/on_demand_scans/graphql/dast_scan_update.mutation.graphql';
import dastOnDemandScanCreateMutation from 'ee/on_demand_scans/graphql/dast_on_demand_scan_create.mutation.graphql';
import dastScannerProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_scanner_profiles.query.graphql';
import dastSiteProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_site_profiles.query.graphql';
import { stubComponent } from 'helpers/stub_component';
import { redirectTo, setUrlParams } from '~/lib/utils/url_utility';
import * as responses from '../mocks/apollo_mocks';
import { scannerProfiles, siteProfiles } from '../mocks/mock_data';

const URL_HOST = 'https://localhost/';
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
const editPath = `/${projectPath}/on_demand_scans/1/edit`;
const [passiveScannerProfile, activeScannerProfile] = scannerProfiles;
const [nonValidatedSiteProfile, validatedSiteProfile] = siteProfiles;
const dastScan = {
  id: 1,
  name: 'My daily scan',
  description: 'Tests for SQL injections',
  scannerProfileId: passiveScannerProfile.id,
  siteProfileId: validatedSiteProfile.id,
};

jest.mock('~/lib/utils/url_utility', () => ({
  isAbsolute: jest.requireActual('~/lib/utils/url_utility').isAbsolute,
  queryToObject: jest.requireActual('~/lib/utils/url_utility').queryToObject,
  setUrlParams: jest.requireActual('~/lib/utils/url_utility').setUrlParams,
  redirectTo: jest.fn(),
}));

describe('OnDemandScansForm', () => {
  let localVue;
  let subject;
  let requestHandlers;

  const GlFormInputStub = stubComponent(GlFormInput, {
    template: '<input />',
  });

  const findForm = () => subject.find(GlForm);
  const findByTestId = (testId) => subject.find(`[data-testid="${testId}"]`);
  const findNameInput = () => findByTestId('dast-scan-name-input');
  const findDescriptionInput = () => findByTestId('dast-scan-description-input');
  const findScannerProfilesSelector = () => subject.find(ScannerProfileSelector);
  const findSiteProfilesSelector = () => subject.find(SiteProfileSelector);
  const findAlert = () => findByTestId('on-demand-scan-error');
  const findProfilesConflictAlert = () => findByTestId('on-demand-scans-profiles-conflict-alert');
  const findSubmitButton = () => findByTestId('on-demand-scan-submit-button');
  const findSaveButton = () => findByTestId('on-demand-scan-save-button');

  const setValidFormData = () => {
    findNameInput().vm.$emit('input', 'My daily scan');
    findScannerProfilesSelector().vm.$emit('input', passiveScannerProfile.id);
    findSiteProfilesSelector().vm.$emit('input', nonValidatedSiteProfile.id);
    return subject.vm.$nextTick();
  };
  const setupSuccess = ({ edit = false } = {}) => {
    jest.spyOn(subject.vm.$apollo, 'mutate').mockResolvedValue({
      data: {
        [edit ? 'dastScanUpdate' : 'dastScanCreate']: {
          dastScan: { editPath },
          pipelineUrl,
          errors: [],
        },
      },
    });
    return setValidFormData();
  };

  const submitForm = () => findForm().vm.$emit('submit', { preventDefault: () => {} });
  const saveScan = () => findSaveButton().vm.$emit('click');

  const createMockApolloProvider = (handlers) => {
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
              dastSavedScans: true,
            },
          },
          stubs: {
            GlFormInput: GlFormInputStub,
          },
        },
        { ...options, localVue, apolloProvider },
        {
          data() {
            return {
              scannerProfiles,
              siteProfiles,
              ...options.data,
            };
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
    expect(subject.text()).toContain('New on-demand DAST scan');
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

  describe('when editing an existing scan', () => {
    beforeEach(() => {
      mountShallowSubject({
        propsData: {
          dastScan,
        },
      });
    });

    it('sets the title properly', () => {
      expect(subject.text()).toContain('Edit on-demand DAST scan');
    });

    it('populates the fields with passed values', () => {
      expect(findNameInput().attributes('value')).toBe(dastScan.name);
      expect(findDescriptionInput().attributes('value')).toBe(dastScan.description);
      expect(findScannerProfilesSelector().attributes('value')).toBe(dastScan.scannerProfileId);
      expect(findSiteProfilesSelector().attributes('value')).toBe(dastScan.siteProfileId);
    });
  });

  describe('submit button', () => {
    let submitButton;

    beforeEach(() => {
      mountShallowSubject();
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
    describe.each`
      action      | actionFunction | submitButtonLoading | saveButtonLoading | runAfterCreate | redirectPath
      ${'submit'} | ${submitForm}  | ${true}             | ${false}          | ${true}        | ${pipelineUrl}
      ${'save'}   | ${saveScan}    | ${false}            | ${true}           | ${false}       | ${editPath}
    `(
      'on $action',
      ({
        actionFunction,
        submitButtonLoading,
        saveButtonLoading,
        runAfterCreate,
        redirectPath,
      }) => {
        describe('with valid form data', () => {
          beforeEach(async () => {
            mountShallowSubject();
            await setupSuccess();
            actionFunction();
          });

          it('sets loading state on correct button', async () => {
            const [submitButton, saveButton] = [findSubmitButton(), findSaveButton()];

            expect(submitButton.props('loading')).toBe(submitButtonLoading);
            expect(submitButton.props('disabled')).toBe(!submitButtonLoading);
            expect(saveButton.props('loading')).toBe(saveButtonLoading);
            expect(saveButton.props('disabled')).toBe(!saveButtonLoading);
          });

          it(`triggers dastScanCreateMutation mutation with runAfterCreate set to ${runAfterCreate}`, async () => {
            expect(subject.vm.$apollo.mutate).toHaveBeenCalledWith({
              mutation: dastScanCreateMutation,
              variables: {
                input: {
                  name: 'My daily scan',
                  description: '',
                  dastScannerProfileId: passiveScannerProfile.id,
                  dastSiteProfileId: nonValidatedSiteProfile.id,
                  fullPath: projectPath,
                  runAfterCreate,
                },
              },
            });
          });

          it('redirects to the URL provided in the response', async () => {
            expect(redirectTo).toHaveBeenCalledWith(redirectPath);
          });

          it('does not show an alert', async () => {
            expect(findAlert().exists()).toBe(false);
          });
        });

        describe('when editing an existing scan', () => {
          beforeEach(async () => {
            mountShallowSubject({
              propsData: {
                dastScan,
              },
            });
            await setupSuccess({ edit: true });
            actionFunction();
          });

          it(`triggers dastScanUpdateMutation mutation with runAfterCreate set to ${runAfterCreate}`, async () => {
            expect(subject.vm.$apollo.mutate).toHaveBeenCalledWith({
              mutation: dastScanUpdateMutation,
              variables: {
                input: {
                  id: 1,
                  name: 'My daily scan',
                  description: 'Tests for SQL injections',
                  dastScannerProfileId: passiveScannerProfile.id,
                  dastSiteProfileId: nonValidatedSiteProfile.id,
                  fullPath: projectPath,
                  runAfterCreate,
                },
              },
            });
          });
        });

        it('does not run any mutation if name is empty', () => {
          mountShallowSubject();
          setValidFormData();
          findNameInput().vm.$emit('input', '');
          actionFunction();

          expect(subject.vm.$apollo.mutate).not.toHaveBeenCalled();
        });
      },
    );

    describe('on top-level error', () => {
      beforeEach(async () => {
        mountShallowSubject();
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
        mountShallowSubject();
        jest
          .spyOn(subject.vm.$apollo, 'mutate')
          .mockResolvedValue({ data: { dastScanCreate: { pipelineUrl: null, errors } } });
        await setValidFormData();
        submitForm();
      });

      it('resets loading state', () => {
        expect(subject.vm.loading).toBe(false);
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

  describe('dastSavedScans feature flag disabled', () => {
    beforeEach(async () => {
      mountShallowSubject({
        provide: {
          glFeatures: {
            dastSavedScans: false,
          },
        },
      });
      jest
        .spyOn(subject.vm.$apollo, 'mutate')
        .mockResolvedValue({ data: { dastOnDemandScanCreate: { pipelineUrl, errors: [] } } });
      subject.find(ScannerProfileSelector).vm.$emit('input', passiveScannerProfile.id);
      subject.find(SiteProfileSelector).vm.$emit('input', nonValidatedSiteProfile.id);
      submitForm();
    });

    it('triggers GraphQL mutation', () => {
      expect(subject.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: dastOnDemandScanCreateMutation,
        variables: {
          input: {
            dastScannerProfileId: passiveScannerProfile.id,
            dastSiteProfileId: nonValidatedSiteProfile.id,
            fullPath: projectPath,
          },
        },
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
          mountShallowSubject();
          await setFormData();

          expect(findProfilesConflictAlert().exists()).toBe(hasConflict);
          expect(findSubmitButton().props('disabled')).toBe(hasConflict);
        },
      );

      describe('securityOnDemandScansSiteValidation feature flag disabled', () => {
        beforeEach(() => {
          mountShallowSubject({
            provide: {
              glFeatures: {
                securityOnDemandScansSiteValidation: false,
              },
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

  describe('site profile summary', () => {
    const [authEnabledProfile] = siteProfiles;

    const selectSiteProfile = (profile) => {
      subject.find(SiteProfileSelector).vm.$emit('input', profile.id);
      return subject.vm.$nextTick();
    };

    beforeEach(() => {
      mountSubject({
        provide: {
          glFeatures: {
            securityDastSiteProfilesAdditionalFields: true,
          },
        },
      });
    });

    it('renders all fields correctly', async () => {
      await selectSiteProfile(authEnabledProfile);
      const summary = subject.find(SiteProfileSelector).text();

      expect(summary).toMatch(authEnabledProfile.targetUrl);
      expect(summary).toMatch(authEnabledProfile.excludedUrls);
      expect(summary).toMatch(authEnabledProfile.requestHeaders);
      expect(summary).toMatch(authEnabledProfile.auth.url);
      expect(summary).toMatch(authEnabledProfile.auth.username);
      expect(summary).toMatch(authEnabledProfile.auth.usernameField);
      expect(summary).toMatch(authEnabledProfile.auth.passwordField);
    });
  });

  describe('populate profiles from query params', () => {
    const [siteProfile] = siteProfiles;
    const [scannerProfile] = scannerProfiles;

    it('scanner profile', () => {
      global.jsdom.reconfigure({
        url: setUrlParams({ scanner_profile_id: 1 }, URL_HOST),
      });
      mountShallowSubject();

      expect(subject.find(ScannerProfileSelector).attributes('value')).toBe(scannerProfile.id);
    });

    it('site profile', () => {
      global.jsdom.reconfigure({
        url: setUrlParams({ site_profile_id: 1 }, URL_HOST),
      });
      mountShallowSubject();

      expect(subject.find(SiteProfileSelector).attributes('value')).toBe(siteProfile.id);
    });

    it('both scanner & site profile', () => {
      global.jsdom.reconfigure({
        url: setUrlParams({ site_profile_id: 1, scanner_profile_id: 1 }, URL_HOST),
      });
      mountShallowSubject();

      expect(subject.find(SiteProfileSelector).attributes('value')).toBe(siteProfile.id);
      expect(subject.find(ScannerProfileSelector).attributes('value')).toBe(scannerProfile.id);
    });
  });
});
