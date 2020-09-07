import merge from 'lodash/merge';
import { within } from '@testing-library/dom';
import { mount, shallowMount } from '@vue/test-utils';
import { GlAlert, GlForm, GlModal } from '@gitlab/ui';
import { TEST_HOST } from 'helpers/test_constants';
import DastSiteProfileForm from 'ee/dast_site_profiles_form/components/dast_site_profile_form.vue';
import DastSiteValidation from 'ee/dast_site_profiles_form/components/dast_site_validation.vue';
import dastSiteProfileCreateMutation from 'ee/dast_site_profiles_form/graphql/dast_site_profile_create.mutation.graphql';
import dastSiteProfileUpdateMutation from 'ee/dast_site_profiles_form/graphql/dast_site_profile_update.mutation.graphql';
import { redirectTo } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility', () => ({
  isAbsolute: jest.requireActual('~/lib/utils/url_utility').isAbsolute,
  redirectTo: jest.fn(),
}));

const fullPath = 'group/project';
const profilesLibraryPath = `${TEST_HOST}/${fullPath}/-/on_demand_scans/profiles`;
const profileName = 'My DAST site profile';
const targetUrl = 'http://example.com';

const defaultProps = {
  profilesLibraryPath,
  fullPath,
};

describe('DastSiteProfileForm', () => {
  let wrapper;

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
  const findAlert = () => wrapper.find(GlAlert);
  const findSiteValidationToggle = () =>
    wrapper.find('[data-testid="dast-site-validation-toggle"]');
  const findDastSiteValidation = () => wrapper.find(DastSiteValidation);

  const componentFactory = (mountFn = shallowMount) => options => {
    wrapper = mountFn(
      DastSiteProfileForm,
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
    wrapper = null;
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
    describe('with feature flag disabled', () => {
      beforeEach(() => {
        createComponent({
          provide: {
            glFeatures: { securityOnDemandScansSiteValidation: false },
          },
        });
      });

      it('does not render validation components', () => {
        expect(findSiteValidationToggle().exists()).toBe(false);
        expect(findDastSiteValidation().exists()).toBe(false);
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
        await targetUrlInput.vm.$emit('input', targetUrl);

        expect(targetUrlInputGroup.attributes('description')).toBeUndefined();
        expect(targetUrlInput.attributes('disabled')).toBeUndefined();

        await findSiteValidationToggle().vm.$emit('change', true);

        expect(targetUrlInputGroup.attributes('description')).toBe(
          'Validation must be turned off to change the target URL',
        );
        expect(targetUrlInput.attributes('disabled')).toBe('true');
      });

      // TODO: refactor this test case when actual GraphQL mutations are implemented
      // See https://gitlab.com/gitlab-org/gitlab/-/issues/238578
      it('when validation section is opened and validation succeeds, section is collapsed', async () => {
        jest.useFakeTimers();
        expect(wrapper.vm.showValidationSection).toBe(false);

        findTargetUrlInput().vm.$emit('input', targetUrl);
        await findSiteValidationToggle().vm.$emit('change', true);
        jest.runAllTimers();
        await wrapper.vm.$nextTick();

        expect(wrapper.vm.showValidationSection).toBe(true);

        await findDastSiteValidation().vm.$emit('success');

        expect(wrapper.vm.showValidationSection).toBe(false);
      });
    });
  });

  describe.each`
    title                  | siteProfile                                 | mutation                         | mutationVars | mutationKind
    ${'New site profile'}  | ${null}                                     | ${dastSiteProfileCreateMutation} | ${{}}        | ${'dastSiteProfileCreate'}
    ${'Edit site profile'} | ${{ id: 1, name: 'foo', targetUrl: 'bar' }} | ${dastSiteProfileUpdateMutation} | ${{ id: 1 }} | ${'dastSiteProfileUpdate'}
  `('$title', ({ siteProfile, title, mutation, mutationVars, mutationKind }) => {
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
      const createdProfileId = 30203;

      describe('on success', () => {
        beforeEach(() => {
          jest
            .spyOn(wrapper.vm.$apollo, 'mutate')
            .mockResolvedValue({ data: { [mutationKind]: { id: createdProfileId } } });
          findProfileNameInput().vm.$emit('input', profileName);
          findTargetUrlInput().vm.$emit('input', targetUrl);
          submitForm();
        });

        it('sets loading state', () => {
          expect(findSubmitButton().props('loading')).toBe(true);
        });

        it('triggers GraphQL mutation', () => {
          expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
            mutation,
            variables: {
              profileName,
              targetUrl,
              fullPath,
              ...mutationVars,
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
          jest.spyOn(wrapper.vm.$apollo, 'mutate').mockRejectedValue();
          const input = findTargetUrlInput();
          input.vm.$emit('input', targetUrl);
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
        const errors = ['error#1', 'error#2', 'error#3'];

        beforeEach(() => {
          jest
            .spyOn(wrapper.vm.$apollo, 'mutate')
            .mockResolvedValue({ data: { [mutationKind]: { errors } } });
          const input = findTargetUrlInput();
          input.vm.$emit('input', targetUrl);
          submitForm();
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
