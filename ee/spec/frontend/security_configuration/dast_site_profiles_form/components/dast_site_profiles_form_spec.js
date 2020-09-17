import merge from 'lodash/merge';
import VueApollo from 'vue-apollo';
import { within } from '@testing-library/dom';
import { createLocalVue, mount, shallowMount } from '@vue/test-utils';
import { createMockClient } from 'mock-apollo-client';
import { GlForm, GlModal } from '@gitlab/ui';
import waitForPromises from 'jest/helpers/wait_for_promises';
import { TEST_HOST } from 'helpers/test_constants';
import DastSiteProfileForm from 'ee/security_configuration/dast_site_profiles_form/components/dast_site_profile_form.vue';
import DastSiteValidation from 'ee/security_configuration/dast_site_profiles_form/components/dast_site_validation.vue';
import dastSiteValidationQuery from 'ee/security_configuration/dast_site_profiles_form/graphql/dast_site_validation.query.graphql';
import dastSiteProfileCreateMutation from 'ee/security_configuration/dast_site_profiles_form/graphql/dast_site_profile_create.mutation.graphql';
import dastSiteProfileUpdateMutation from 'ee/security_configuration/dast_site_profiles_form/graphql/dast_site_profile_update.mutation.graphql';
import dastSiteTokenCreateMutation from 'ee/security_configuration/dast_site_profiles_form/graphql/dast_site_token_create.mutation.graphql';
import * as responses from 'ee_jest/security_configuration/dast_site_profiles_form/mock_data/apollo_mock';
import { redirectTo } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility', () => ({
  isAbsolute: jest.requireActual('~/lib/utils/url_utility').isAbsolute,
  redirectTo: jest.fn(),
}));

const localVue = createLocalVue();
localVue.use(VueApollo);

const fullPath = 'group/project';
const profilesLibraryPath = `${TEST_HOST}/${fullPath}/-/security/configuration/dast_profiles`;
const profileName = 'My DAST site profile';
const targetUrl = 'http://example.com';
const tokenId = '3455';
const token = '33988';

const defaultProps = {
  profilesLibraryPath,
  fullPath,
};

const defaultRequestHandlers = {
  dastSiteProfileCreate: jest.fn().mockResolvedValue(responses.dastSiteProfileCreate()),
  dastSiteProfileUpdate: jest.fn().mockResolvedValue(responses.dastSiteProfileUpdate()),
  dastSiteTokenCreate: jest
    .fn()
    .mockResolvedValue(responses.dastSiteTokenCreate({ id: tokenId, token })),
  dastSiteValidation: jest.fn().mockResolvedValue(responses.dastSiteValidation()),
};

describe('DastSiteProfileForm', () => {
  let wrapper;
  let apolloProvider;
  let requestHandlers;

  const withinComponent = () => within(wrapper.element);

  const findForm = () => wrapper.find(GlForm);
  const findProfileNameInput = () => wrapper.find('[data-testid="profile-name-input"]');
  const findTargetUrlInputGroup = () => wrapper.find('[data-testid="target-url-input-group"]');
  const findTargetUrlInput = () => wrapper.find('[data-testid="target-url-input"]');
  const findSubmitButton = () =>
    wrapper.find('[data-testid="dast-site-profile-form-submit-button"]');
  const findCancelButton = () =>
    wrapper.find('[data-testid="dast-site-profile-form-cancel-button"]');
  const findCancelModal = () => wrapper.find(GlModal);
  const submitForm = () => findForm().vm.$emit('submit', { preventDefault: () => {} });
  const findAlert = () => wrapper.find('[data-testid="dast-site-profile-form-alert"]');
  const findSiteValidationToggle = () =>
    wrapper.find('[data-testid="dast-site-validation-toggle"]');
  const findDastSiteValidation = () => wrapper.find(DastSiteValidation);

  const mockClientFactory = handlers => {
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

    mockClient.setRequestHandler(dastSiteTokenCreateMutation, requestHandlers.dastSiteTokenCreate);

    mockClient.setRequestHandler(dastSiteValidationQuery, requestHandlers.dastSiteValidation);

    return mockClient;
  };

  const respondWith = handlers => {
    apolloProvider.defaultClient = mockClientFactory(handlers);
  };

  const componentFactory = (mountFn = shallowMount) => options => {
    apolloProvider = new VueApollo({
      defaultClient: mockClientFactory(),
    });

    const mountOpts = merge(
      {},
      {
        propsData: defaultProps,
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

  describe('submit button', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('is disabled if', () => {
      it('form contains errors', async () => {
        findProfileNameInput().vm.$emit('input', profileName);
        await findTargetUrlInput().vm.$emit('input', 'invalid URL');
        expect(findSubmitButton().props('disabled')).toBe(true);
      });

      it('at least one field is empty', async () => {
        findProfileNameInput().vm.$emit('input', '');
        await findTargetUrlInput().vm.$emit('input', targetUrl);
        expect(findSubmitButton().props('disabled')).toBe(true);
      });
    });

    describe('is enabled if', () => {
      it('all fields are filled in and valid', async () => {
        findProfileNameInput().vm.$emit('input', profileName);
        await findTargetUrlInput().vm.$emit('input', targetUrl);
        expect(findSubmitButton().props('disabled')).toBe(false);
      });
    });
  });

  describe('target URL input', () => {
    const errorMessage = 'Please enter a valid URL format, ex: http://www.example.com/home';

    beforeEach(() => {
      createFullComponent();
    });

    it.each(['asd', 'example.com'])('is marked as invalid provided an invalid URL', async value => {
      findTargetUrlInput().setValue(value);
      await wrapper.vm.$nextTick();

      expect(wrapper.text()).toContain(errorMessage);
    });

    it('is marked as valid provided a valid URL', async () => {
      findTargetUrlInput().setValue(targetUrl);
      await wrapper.vm.$nextTick();

      expect(wrapper.text()).not.toContain(errorMessage);
    });
  });

  describe('validation', () => {
    const enableValidationToggle = async () => {
      await findTargetUrlInput().vm.$emit('input', targetUrl);
      await findSiteValidationToggle().vm.$emit('change', true);
    };

    describe.each`
      title                  | siteProfile
      ${'New site profile'}  | ${null}
      ${'Edit site profile'} | ${{ id: 1, name: 'foo', targetUrl: 'bar' }}
    `('$title with feature flag disabled', ({ siteProfile }) => {
      beforeEach(() => {
        createComponent({
          provide: {
            glFeatures: { securityOnDemandScansSiteValidation: false },
          },
          propsData: {
            siteProfile,
          },
        });
      });

      it('does not render validation components', () => {
        expect(findSiteValidationToggle().exists()).toBe(false);
        expect(findDastSiteValidation().exists()).toBe(false);
      });

      it('does not check the target URLs validation status', () => {
        expect(requestHandlers.dastSiteValidation).not.toHaveBeenCalled();
      });
    });

    describe('with feature flag enabled', () => {
      beforeEach(() => {
        createComponent({
          provide: {
            glFeatures: { securityOnDemandScansSiteValidation: true },
          },
        });
      });

      it('renders validation components', () => {
        expect(findSiteValidationToggle().exists()).toBe(true);
        expect(findDastSiteValidation().exists()).toBe(true);
      });

      it('toggle is disabled until target URL is valid', async () => {
        expect(findSiteValidationToggle().props('disabled')).toBe(true);

        await findTargetUrlInput().vm.$emit('input', targetUrl);

        expect(findSiteValidationToggle().props('disabled')).toBe(false);
      });

      it('disables target URL input when validation is enabled', async () => {
        const targetUrlInputGroup = findTargetUrlInputGroup();
        const targetUrlInput = findTargetUrlInput();

        expect(targetUrlInputGroup.attributes('description')).toBeUndefined();
        expect(targetUrlInput.attributes('disabled')).toBeUndefined();

        await enableValidationToggle();
        await waitForPromises();

        expect(targetUrlInputGroup.attributes('description')).toBe(
          'Validation must be turned off to change the target URL',
        );
        expect(targetUrlInput.attributes('disabled')).toBe('true');
      });

      it('checks the target URLs validation status when validation is enabled', async () => {
        expect(requestHandlers.dastSiteValidation).not.toHaveBeenCalled();

        await enableValidationToggle();

        expect(requestHandlers.dastSiteValidation).toHaveBeenCalledWith({
          fullPath,
          targetUrl,
        });
      });

      it('creates a site token if the target URL has not been validated', async () => {
        expect(requestHandlers.dastSiteTokenCreate).not.toHaveBeenCalled();

        await enableValidationToggle();
        await waitForPromises();

        expect(requestHandlers.dastSiteTokenCreate).toHaveBeenCalledWith({
          projectFullPath: fullPath,
          targetUrl,
        });

        expect(findDastSiteValidation().props()).toMatchObject({
          tokenId,
          token,
        });
      });

      it.each`
        description                                             | failingResponse          | errorMessageStart
        ${'target URLs validation status can not be retrieved'} | ${'dastSiteValidation'}  | ${'Could not retrieve site validation status'}
        ${'validation token can not be created'}                | ${'dastSiteTokenCreate'} | ${'Could not create site validation token'}
      `('shows an error if $description', async ({ failingResponse, errorMessageStart }) => {
        respondWith({
          [failingResponse]: jest.fn().mockRejectedValue(),
        });

        expect(findAlert().exists()).toBe(false);

        await enableValidationToggle();
        await waitForPromises();

        expect(findAlert().exists()).toBe(true);
        expect(findAlert().text()).toBe(
          `${errorMessageStart}. Please refresh the page, or try again later.`,
        );
      });

      it('when validation section is opened and validation succeeds, section is collapsed', async () => {
        expect(wrapper.vm.showValidationSection).toBe(false);

        await enableValidationToggle();
        await waitForPromises();

        expect(wrapper.vm.showValidationSection).toBe(true);

        await findDastSiteValidation().vm.$emit('success');

        expect(wrapper.vm.showValidationSection).toBe(false);
      });
    });
  });

  describe.each`
    title                  | siteProfile                                 | mutationVars | mutationKind
    ${'New site profile'}  | ${null}                                     | ${{}}        | ${'dastSiteProfileCreate'}
    ${'Edit site profile'} | ${{ id: 1, name: 'foo', targetUrl: 'bar' }} | ${{ id: 1 }} | ${'dastSiteProfileUpdate'}
  `('$title', ({ siteProfile, title, mutationVars, mutationKind }) => {
    beforeEach(() => {
      createFullComponent({
        propsData: {
          siteProfile,
        },
      });
    });

    it('sets the correct title', () => {
      expect(withinComponent().getByRole('heading', { name: title })).not.toBeNull();
    });

    it('populates the fields with the data passed in via the siteProfile prop', () => {
      expect(findProfileNameInput().element.value).toBe(siteProfile?.name ?? '');
    });

    describe('submission', () => {
      describe('on success', () => {
        beforeEach(() => {
          findProfileNameInput().vm.$emit('input', profileName);
          findTargetUrlInput().vm.$emit('input', targetUrl);
          submitForm();
        });

        it('sets loading state', () => {
          expect(findSubmitButton().props('loading')).toBe(true);
        });

        it('triggers GraphQL mutation', () => {
          expect(requestHandlers[mutationKind]).toHaveBeenCalledWith({
            profileName,
            targetUrl,
            fullPath,
            ...mutationVars,
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
          respondWith({
            [mutationKind]: jest.fn().mockRejectedValue(new Error('GraphQL Network Error')),
          });

          const input = findTargetUrlInput();
          input.vm.$emit('input', targetUrl);
          submitForm();

          return waitForPromises();
        });

        it('resets loading state', () => {
          expect(findSubmitButton().props('loading')).toBe(false);
        });

        it('shows an error alert', () => {
          expect(findAlert().exists()).toBe(true);
        });
      });

      describe('on errors as data', () => {
        const errors = ['error#1', 'error#2', 'error#3'];

        beforeEach(() => {
          respondWith({
            [mutationKind]: jest.fn().mockResolvedValue(responses[mutationKind](errors)),
          });

          const input = findTargetUrlInput();
          input.vm.$emit('input', targetUrl);
          submitForm();

          return waitForPromises();
        });

        it('resets loading state', () => {
          expect(findSubmitButton().props('loading')).toBe(false);
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

    describe('cancellation', () => {
      describe('form unchanged', () => {
        it('redirects to the profiles library', () => {
          findCancelButton().vm.$emit('click');
          expect(redirectTo).toHaveBeenCalledWith(profilesLibraryPath);
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
          expect(redirectTo).toHaveBeenCalledWith(profilesLibraryPath);
        });
      });
    });
  });
});
