import { GlForm, GlModal } from '@gitlab/ui';
import { within } from '@testing-library/dom';
import { createLocalVue, mount, shallowMount } from '@vue/test-utils';
import merge from 'lodash/merge';
import { createMockClient } from 'mock-apollo-client';
import VueApollo from 'vue-apollo';
import DastSiteProfileForm from 'ee/security_configuration/dast_site_profiles_form/components/dast_site_profile_form.vue';
import DastSiteAuthSection from 'ee/security_configuration/dast_site_profiles_form/components/dast_site_auth_section.vue';
import dastSiteProfileCreateMutation from 'ee/security_configuration/dast_site_profiles_form/graphql/dast_site_profile_create.mutation.graphql';
import dastSiteProfileUpdateMutation from 'ee/security_configuration/dast_site_profiles_form/graphql/dast_site_profile_update.mutation.graphql';
import { siteProfiles } from 'ee_jest/on_demand_scans/mocks/mock_data';
import * as responses from 'ee_jest/security_configuration/dast_site_profiles_form/mock_data/apollo_mock';
import { TEST_HOST } from 'helpers/test_constants';
import waitForPromises from 'helpers/wait_for_promises';
import * as urlUtility from '~/lib/utils/url_utility';

const localVue = createLocalVue();
localVue.use(VueApollo);

const [siteProfileOne] = siteProfiles;
const fullPath = 'group/project';
const profilesLibraryPath = `${TEST_HOST}/${fullPath}/-/security/configuration/dast_profiles`;
const onDemandScansPath = `${TEST_HOST}/${fullPath}/-/on_demand_scans`;
const profileName = 'My DAST site profile';
const targetUrl = 'http://example.com';
const excludedUrls = 'http://example.com/logout';
const requestHeaders = 'my-new-header=something';

const defaultProps = {
  profilesLibraryPath,
  fullPath,
  onDemandScansPath,
};

const defaultRequestHandlers = {
  dastSiteProfileCreate: jest.fn().mockResolvedValue(responses.dastSiteProfileCreate()),
  dastSiteProfileUpdate: jest.fn().mockResolvedValue(responses.dastSiteProfileUpdate()),
};

describe('DastSiteProfileForm', () => {
  let wrapper;
  let apolloProvider;
  let requestHandlers;

  const withinComponent = () => within(wrapper.element);

  const findForm = () => wrapper.find(GlForm);
  const findByTestId = (testId) => wrapper.find(`[data-testid="${testId}"]`);
  const findProfileNameInput = () => findByTestId('profile-name-input');
  const findTargetUrlInput = () => findByTestId('target-url-input');
  const findAuthSection = () => wrapper.find(DastSiteAuthSection);
  const findExcludedUrlsInput = () => findByTestId('excluded-urls-input');
  const findRequestHeadersInput = () => findByTestId('request-headers-input');
  const findSubmitButton = () => findByTestId('dast-site-profile-form-submit-button');
  const findCancelButton = () => findByTestId('dast-site-profile-form-cancel-button');
  const findCancelModal = () => wrapper.find(GlModal);
  const submitForm = () => findForm().vm.$emit('submit', { preventDefault: () => {} });
  const findAlert = () => findByTestId('dast-site-profile-form-alert');

  const setFieldValue = async (field, value) => {
    await field.setValue(value);
    field.trigger('blur');
  };

  const mockClientFactory = (handlers) => {
    const mockClient = createMockClient();

    requestHandlers = {
      ...defaultRequestHandlers,
      ...handlers,
    };

    mockClient.setRequestHandler(
      dastSiteProfileCreateMutation,
      requestHandlers.dastSiteProfileCreate,
    );

    mockClient.setRequestHandler(
      dastSiteProfileUpdateMutation,
      requestHandlers.dastSiteProfileUpdate,
    );

    return mockClient;
  };

  const respondWith = (handlers) => {
    apolloProvider.defaultClient = mockClientFactory(handlers);
  };

  const componentFactory = (mountFn = shallowMount) => (options, handlers) => {
    apolloProvider = new VueApollo({
      defaultClient: mockClientFactory(handlers),
    });

    const mountOpts = merge(
      {},
      {
        propsData: defaultProps,
        provide: {
          glFeatures: {
            securityDastSiteProfilesAdditionalFields: true,
          },
        },
      },
      options,
      {
        localVue,
        apolloProvider,
      },
    );

    wrapper = mountFn(DastSiteProfileForm, mountOpts);
  };
  const createComponent = componentFactory();
  const createFullComponent = componentFactory(mount);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    apolloProvider = null;
  });

  it('renders properly', () => {
    createComponent();
    expect(wrapper.html()).not.toBe('');
  });

  describe('target URL input', () => {
    const errorMessage = 'Please enter a valid URL format, ex: http://www.example.com/home';

    beforeEach(() => {
      createFullComponent();
    });

    it.each(['asd', 'example.com'])(
      'is marked as invalid provided an invalid URL',
      async (value) => {
        await setFieldValue(findTargetUrlInput(), value);

        expect(wrapper.text()).toContain(errorMessage);
      },
    );

    it('is marked as valid provided a valid URL', async () => {
      await setFieldValue(findTargetUrlInput(), targetUrl);

      expect(wrapper.text()).not.toContain(errorMessage);
    });
  });

  describe('additional fields', () => {
    beforeEach(() => {
      createFullComponent();
    });

    it('should render correctly', () => {
      expect(findAuthSection().exists()).toBe(true);
      expect(findExcludedUrlsInput().exists()).toBe(true);
      expect(findRequestHeadersInput().exists()).toBe(true);
    });
  });

  describe.each`
    title                  | siteProfile       | mutationVars                 | mutationKind
    ${'New site profile'}  | ${null}           | ${{}}                        | ${'dastSiteProfileCreate'}
    ${'Edit site profile'} | ${siteProfileOne} | ${{ id: siteProfileOne.id }} | ${'dastSiteProfileUpdate'}
  `('$title', ({ siteProfile, title, mutationVars, mutationKind }) => {
    beforeEach(() => {
      createFullComponent({
        propsData: {
          siteProfile,
        },
      });

      jest.spyOn(urlUtility, 'redirectTo').mockImplementation();
    });

    it('sets the correct title', () => {
      expect(withinComponent().getByRole('heading', { name: title })).not.toBeNull();
    });

    it('populates the fields with the data passed in via the siteProfile prop', () => {
      expect(findProfileNameInput().element.value).toBe(siteProfile?.name ?? '');
    });

    describe('submission', () => {
      const fillAndSubmitForm = async () => {
        await setFieldValue(findProfileNameInput(), profileName);
        await setFieldValue(findTargetUrlInput(), targetUrl);
        await setFieldValue(findExcludedUrlsInput(), excludedUrls);
        await setFieldValue(findRequestHeadersInput(), requestHeaders);
        submitForm();
      };

      describe('on success', () => {
        beforeEach(async () => {
          await fillAndSubmitForm();
        });

        it('sets loading state', () => {
          expect(findSubmitButton().props('loading')).toBe(true);
        });

        it('triggers GraphQL mutation', () => {
          expect(requestHandlers[mutationKind]).toHaveBeenCalledWith({
            input: {
              profileName,
              targetUrl,
              excludedUrls,
              requestHeaders,
              fullPath,
              ...mutationVars,
            },
          });
        });

        it('redirects to the profiles library', () => {
          expect(urlUtility.redirectTo).toHaveBeenCalledWith(profilesLibraryPath);
        });

        it('does not show an alert', () => {
          expect(findAlert().exists()).toBe(false);
        });
      });

      describe('on top-level error', () => {
        beforeEach(async () => {
          respondWith({
            [mutationKind]: jest.fn().mockRejectedValue(new Error('GraphQL Network Error')),
          });

          await fillAndSubmitForm();
          await waitForPromises();
        });

        it('resets loading state', () => {
          expect(findSubmitButton().props('loading')).toBe(false);
        });

        it('shows an error alert', async () => {
          await wrapper.vm.$nextTick();

          expect(findAlert().exists()).toBe(true);
        });
      });

      describe('on errors as data', () => {
        const errors = ['error#1', 'error#2', 'error#3'];

        beforeEach(async () => {
          respondWith({
            [mutationKind]: jest.fn().mockResolvedValue(responses[mutationKind](errors)),
          });

          await fillAndSubmitForm();
          await waitForPromises();
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
      describe('form unchanged', () => {
        it('redirects to the profiles library', () => {
          findCancelButton().vm.$emit('click');
          expect(urlUtility.redirectTo).toHaveBeenCalledWith(profilesLibraryPath);
        });
      });

      describe('form changed', () => {
        beforeEach(() => {
          findTargetUrlInput().setValue(targetUrl);
          findProfileNameInput().setValue(profileName);
        });

        it('asks the user to confirm the action', () => {
          jest.spyOn(findCancelModal().vm, 'show').mockReturnValue();
          findCancelButton().trigger('click');
          expect(findCancelModal().vm.show).toHaveBeenCalled();
        });

        it('redirects to the profiles library if confirmed', () => {
          findCancelModal().vm.$emit('ok');
          expect(urlUtility.redirectTo).toHaveBeenCalledWith(profilesLibraryPath);
        });
      });
    });
  });

  describe('when feature flag is off', () => {
    beforeEach(() => {
      createFullComponent({
        provide: {
          glFeatures: {
            securityDastSiteProfilesAdditionalFields: false,
          },
        },
      });
    });

    it('should not render additional fields', () => {
      expect(findAuthSection().exists()).toBe(false);
      expect(findExcludedUrlsInput().exists()).toBe(false);
      expect(findRequestHeadersInput().exists()).toBe(false);
    });
  });
});
