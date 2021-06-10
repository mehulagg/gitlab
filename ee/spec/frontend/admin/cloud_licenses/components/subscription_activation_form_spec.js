import { GlForm, GlFormCheckbox, GlFormInput } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import SubscriptionActivationForm, {
  SUBSCRIPTION_ACTIVATION_FAILURE_EVENT,
  SUBSCRIPTION_ACTIVATION_SUCCESS_EVENT,
} from 'ee/pages/admin/cloud_licenses/components/subscription_activation_form.vue';
import {
  CONNECTIVITY_ERROR,
  fieldRequiredMessage,
  INVALID_CODE_ERROR,
  subscriptionQueries,
} from 'ee/pages/admin/cloud_licenses/constants';
import createMockApollo from 'helpers/mock_apollo_helper';
import { stubComponent } from 'helpers/stub_component';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { preventDefault, stopPropagation } from '../../test_helpers';
import { activateLicenseMutationResponse } from '../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('CloudLicenseApp', () => {
  let wrapper;

  const fakeActivationCode = 'gEg959hDCkvM2d4Der5RyktT ';
  const fakeActivationCodeTrimmed = 'gEg959hDCkvM2d4Der5RyktT';

  const createMockApolloProvider = (resolverMock) => {
    localVue.use(VueApollo);
    return createMockApollo([[subscriptionQueries.mutation, resolverMock]]);
  };

  const findActivateButton = () => wrapper.findByTestId('activate-button');
  const findAgreementCheckbox = () => wrapper.findComponent(GlFormCheckbox);
  const findAgreementCheckboxFormGroup = () => wrapper.findByTestId('form-group-terms');
  const findActivationCodeFormGroup = () => wrapper.findByTestId('form-group-activation-code');
  const findActivationCodeInput = () => wrapper.findComponent(GlFormInput);
  const findActivateSubscriptionForm = () => wrapper.findComponent(GlForm);

  const GlFormInputStub = stubComponent(GlFormInput, {
    template: `<input />`,
  });

  const createFakeEvent = () => ({
    preventDefault,
    stopPropagation,
  });

  const createComponentWithApollo = ({ props = {}, mutationMock } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(SubscriptionActivationForm, {
        localVue,
        apolloProvider: createMockApolloProvider(mutationMock),
        propsData: {
          ...props,
        },
        stubs: {
          GlFormInput: GlFormInputStub,
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Subscription Activation Form', () => {
    beforeEach(() => createComponentWithApollo());

    it('presents a form', () => {
      expect(findActivateSubscriptionForm().exists()).toBe(true);
    });

    it('has an input', () => {
      expect(findActivationCodeInput().exists()).toBe(true);
    });

    it('has an `Activate` button', () => {
      expect(findActivateButton().text()).toBe('Activate');
    });

    it('has a checkbox to accept subscription agreement', () => {
      expect(findAgreementCheckbox().exists()).toBe(true);
    });

    it('has the activate button enabled', () => {
      expect(findActivateButton().props('disabled')).toBe(false);
    });
  });

  describe('form errors', () => {
    const mutationMock = jest.fn();
    beforeEach(() => {
      createComponentWithApollo({ mutationMock });
    });

    it('shows an error for the text field', async () => {
      await findActivateSubscriptionForm().vm.$emit('submit', createFakeEvent());

      expect(findActivationCodeFormGroup().attributes('invalid-feedback')).toBe(
        'Please fill out this field.',
      );
    });

    it('shows an error for the checkbox field', async () => {
      await findActivationCodeInput().vm.$emit('input', fakeActivationCode);

      expect(findAgreementCheckboxFormGroup().attributes('invalid-feedback')).toBe(
        fieldRequiredMessage,
      );
    });

    it('does not perform any mutation', () => {
      expect(mutationMock).toHaveBeenCalledTimes(0);
    });
  });

  describe('activate the subscription', () => {
    describe('when submitting the mutation is successful', () => {
      const mutationMock = jest.fn().mockResolvedValue(activateLicenseMutationResponse.SUCCESS);
      beforeEach(async () => {
        createComponentWithApollo({ mutationMock });
        jest.spyOn(wrapper.vm, 'updateSubscriptionAppCache').mockImplementation();
        await findActivationCodeInput().vm.$emit('input', fakeActivationCode);
        await findAgreementCheckbox().vm.$emit('input', true);
        findActivateSubscriptionForm().vm.$emit('submit', createFakeEvent());
      });

      it('prevents default submit', () => {
        expect(preventDefault).toHaveBeenCalled();
      });

      it('calls mutate with the correct variables', () => {
        expect(mutationMock).toHaveBeenCalledWith({
          gitlabSubscriptionActivateInput: {
            activationCode: fakeActivationCodeTrimmed,
          },
        });
      });

      it('emits a successful event', () => {
        expect(wrapper.emitted(SUBSCRIPTION_ACTIVATION_SUCCESS_EVENT)).toEqual([[]]);
      });

      it('calls the method to update the cache', () => {
        expect(wrapper.vm.updateSubscriptionAppCache).toHaveBeenCalledTimes(1);
      });
    });

    describe('when the mutation is not successful', () => {
      const mutationMock = jest
        .fn()
        .mockResolvedValue(activateLicenseMutationResponse.ERRORS_AS_DATA);
      beforeEach(() => {
        createComponentWithApollo({ mutationMock });
        findActivateSubscriptionForm().vm.$emit('submit', createFakeEvent());
      });

      it('emits a unsuccessful event', () => {
        expect(wrapper.emitted(SUBSCRIPTION_ACTIVATION_FAILURE_EVENT)).toBeUndefined();
      });
    });

    describe('when the mutation is not successful with connectivity error', () => {
      const mutationMock = jest
        .fn()
        .mockResolvedValue(activateLicenseMutationResponse.CONNECTIVITY_ERROR);
      beforeEach(async () => {
        createComponentWithApollo({ mutationMock });
        await findActivationCodeInput().vm.$emit('input', fakeActivationCode);
        await findAgreementCheckbox().vm.$emit('input', true);
        findActivateSubscriptionForm().vm.$emit('submit', createFakeEvent());
      });

      it('emits an failure event with a connectivity error payload', () => {
        expect(wrapper.emitted(SUBSCRIPTION_ACTIVATION_FAILURE_EVENT)).toEqual([
          [CONNECTIVITY_ERROR],
        ]);
      });
    });

    describe('when the mutation is not successful with invalid activation code error', () => {
      const mutationMock = jest
        .fn()
        .mockResolvedValue(activateLicenseMutationResponse.INVALID_CODE_ERROR);
      beforeEach(async () => {
        createComponentWithApollo({ mutationMock });
        await findActivationCodeInput().vm.$emit('input', fakeActivationCode);
        await findAgreementCheckbox().vm.$emit('input', true);
        findActivateSubscriptionForm().vm.$emit('submit', createFakeEvent());
      });

      it('emits an failure event with a connectivity error payload', () => {
        expect(wrapper.emitted(SUBSCRIPTION_ACTIVATION_FAILURE_EVENT)).toEqual([
          [INVALID_CODE_ERROR],
        ]);
      });
    });

    describe('when the mutation request fails', () => {
      const mutationMock = jest.fn().mockRejectedValue(activateLicenseMutationResponse.FAILURE);
      beforeEach(() => {
        createComponentWithApollo({ mutationMock });
        findActivateSubscriptionForm().vm.$emit('submit', createFakeEvent());
      });

      it('emits a unsuccessful event', () => {
        expect(wrapper.emitted(SUBSCRIPTION_ACTIVATION_FAILURE_EVENT)).toBeUndefined();
      });
    });
  });
});
