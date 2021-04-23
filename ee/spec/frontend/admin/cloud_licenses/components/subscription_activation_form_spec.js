import { GlForm, GlFormInput, GlFormCheckbox } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import CloudLicenseSubscriptionActivationForm, {
  SUBSCRIPTION_ACTIVATION_EVENT,
} from 'ee/pages/admin/cloud_licenses/components/subscription_activation_form.vue';
import { subscriptionQueries } from 'ee/pages/admin/cloud_licenses/constants';
import createMockApollo from 'helpers/mock_apollo_helper';
import { stubComponent } from 'helpers/stub_component';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { preventDefault, stopPropagation } from '../../test_helpers';
import { activateLicenseMutationResponse } from '../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('CloudLicenseApp', () => {
  let wrapper;

  const fakeActivationCode = 'gEg959hDCkvM2d4Der5RyktT';

  const createMockApolloProvider = (resolverMock) => {
    localVue.use(VueApollo);
    return createMockApollo([[subscriptionQueries.mutation, resolverMock]]);
  };

  const findActivateButton = () => wrapper.findByTestId('activate-button');
  const findAgreementCheckbox = () => wrapper.findComponent(GlFormCheckbox);
  const findActivationCodeInput = () => wrapper.findComponent(GlFormInput);
  const findActivateSubscriptionForm = () => wrapper.findComponent(GlForm);
  const enableAcceptAgreementCheckbox = () => findAgreementCheckbox().vm.$emit('input', true);

  const GlFormInputStub = stubComponent(GlFormInput, {
    template: `<input />`,
  });

  const createFakeEvent = () => ({
    preventDefault,
    stopPropagation,
  });

  const createComponentWithApollo = (props = {}, resolverMock) => {
    wrapper = extendedWrapper(
      shallowMount(CloudLicenseSubscriptionActivationForm, {
        localVue,
        apolloProvider: createMockApolloProvider(resolverMock),
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

    it('disables the activate button if the agreement is unaccepted', () => {
      expect(findActivateButton().props('disabled')).toBe(true);
    });

    it('enables the activate button if the agreement is accepted', async () => {
      expect(findActivateButton().props('disabled')).toBe(true);
      enableAcceptAgreementCheckbox();
      await wrapper.vm.$nextTick();

      expect(findActivateButton().props('disabled')).toBe(false);
    });
  });

  describe('Activate the subscription', () => {
    describe('when submitting the form', () => {
      const mutationMock = jest.fn().mockResolvedValue(activateLicenseMutationResponse.SUCCESS);
      beforeEach(() => {
        createComponentWithApollo({}, mutationMock);
        findActivationCodeInput().vm.$emit('input', fakeActivationCode);
        findActivateSubscriptionForm().vm.$emit('submit', createFakeEvent());
      });

      it('prevents default submit', () => {
        expect(preventDefault).toHaveBeenCalled();
      });

      it('calls mutate with the correct variables', () => {
        expect(mutationMock).toHaveBeenCalledWith({
          gitlabSubscriptionActivateInput: {
            activationCode: fakeActivationCode,
          },
        });
      });
    });

    describe('when the mutation is successful', () => {
      beforeEach(() => {
        createComponentWithApollo(
          {},
          jest.fn().mockResolvedValue(activateLicenseMutationResponse.SUCCESS),
        );
        findActivationCodeInput().vm.$emit('input', fakeActivationCode);
        findActivateSubscriptionForm().vm.$emit('submit', createFakeEvent());
      });

      it('emits a successful event', () => {
        expect(wrapper.emitted(SUBSCRIPTION_ACTIVATION_EVENT)).toEqual([[true]]);
      });
    });

    describe('when the mutation is not successful but looks like it is', () => {
      beforeEach(() => {
        createComponentWithApollo(
          {},
          jest.fn().mockResolvedValue(activateLicenseMutationResponse.FAILURE_IN_DISGUISE),
        );
        findActivateSubscriptionForm().vm.$emit('submit', createFakeEvent());
      });

      it('emits a successful event', () => {
        expect(wrapper.emitted(SUBSCRIPTION_ACTIVATION_EVENT)).toBeUndefined();
      });

      it.todo('deals with failures in a meaningful way');
    });

    describe('when the mutation is not successful', () => {
      beforeEach(() => {
        createComponentWithApollo(
          {},
          jest.fn().mockRejectedValue(activateLicenseMutationResponse.FAILURE),
        );
        findActivateSubscriptionForm().vm.$emit('submit', createFakeEvent());
      });

      it('emits a successful event', () => {
        expect(wrapper.emitted(SUBSCRIPTION_ACTIVATION_EVENT)).toBeUndefined();
      });

      it.todo('deals with failures in a meaningful way');
    });
  });
});
