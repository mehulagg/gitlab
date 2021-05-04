import { GlModal } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SubscriptionActivationErrors from 'ee/pages/admin/cloud_licenses/components/subscription_activation_errors.vue';
import SubscriptionActivationForm, {
  SUBSCRIPTION_ACTIVATION_FAILURE_EVENT,
  SUBSCRIPTION_ACTIVATION_SUCCESS_EVENT,
} from 'ee/pages/admin/cloud_licenses/components/subscription_activation_form.vue';
import SubscriptionActivationModal from 'ee/pages/admin/cloud_licenses/components/subscription_activation_modal.vue';
import {
  activateSubscription,
  CONNECTIVITY_ERROR,
  subscriptionActivationInsertCode,
} from 'ee/pages/admin/cloud_licenses/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { preventDefault } from '../../test_helpers';

describe('SubscriptionActivationModal', () => {
  let wrapper;

  const modalId = 'fake-modal-id';
  const findGlModal = () => wrapper.findComponent(GlModal);
  const findSubscriptionActivationErrors = () =>
    wrapper.findComponent(SubscriptionActivationErrors);
  const findSubscriptionActivationForm = () => wrapper.findComponent(SubscriptionActivationForm);

  const createComponent = ({ props = {}, stubs = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(SubscriptionActivationModal, {
        propsData: {
          modalId,
          ...props,
        },
        stubs,
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('idle state', () => {
    beforeEach(() => {
      createComponent();
    });

    it('has an id', () => {
      expect(findGlModal().attributes('modalid')).toBe(modalId);
    });

    it('shows a description text', () => {
      expect(wrapper.text()).toContain(subscriptionActivationInsertCode);
    });

    it('shows a title', () => {
      expect(findGlModal().attributes('title')).toBe(activateSubscription);
    });

    it('shows the subscription activation form', () => {
      expect(findSubscriptionActivationForm().exists()).toBe(true);
    });

    it('hides the form default button', () => {
      expect(findSubscriptionActivationForm().props('hideSubmitButton')).toBe(true);
    });

    it('does not show any error', () => {
      expect(findSubscriptionActivationErrors().exists()).toBe(false);
    });
  });

  describe('subscription activation', () => {
    const fakeEvent = 'fake-modal-event';
    const hiddenEven = 'hidden';

    describe('when submitting the form', () => {
      beforeEach(() => {
        createComponent();
        jest
          .spyOn(wrapper.vm, 'handlePrimary')
          .mockImplementation(() => wrapper.vm.$emit(fakeEvent));
        findGlModal().vm.$emit('primary', { preventDefault });
      });

      it('emits the correct event', () => {
        expect(wrapper.emitted(fakeEvent)).toEqual([[]]);
      });
    });

    describe('successful activation', () => {
      beforeEach(() => {
        createComponent({ stubs: { GlModal } });
        jest
          .spyOn(wrapper.vm.$refs.modal, 'hide')
          .mockImplementation(() => wrapper.vm.$emit(hiddenEven));
        findSubscriptionActivationForm().vm.$emit(SUBSCRIPTION_ACTIVATION_SUCCESS_EVENT);
      });

      it('it emits a hidden event', () => {
        expect(wrapper.emitted(hiddenEven)).toEqual([[]]);
      });
    });

    describe('failing activation', () => {
      beforeEach(() => {
        createComponent();
        findSubscriptionActivationForm().vm.$emit(
          SUBSCRIPTION_ACTIVATION_FAILURE_EVENT,
          CONNECTIVITY_ERROR,
        );
      });

      it('passes the correct props', () => {
        expect(findSubscriptionActivationErrors().props('error')).toBe(CONNECTIVITY_ERROR);
      });

      it('resets the component state when closing', async () => {
        await findGlModal().vm.$emit('hidden');

        expect(findSubscriptionActivationErrors().exists()).toBe(false);
      });
    });
  });
});
