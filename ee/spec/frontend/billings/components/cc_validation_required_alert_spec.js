import { GlAlert, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AccountVerificationModal from 'ee/billings/components/account_verification_modal.vue';
import CreditCardValidationRequiredAlert from 'ee/billings/components/cc_validation_required_alert.vue';
import { TEST_HOST } from 'helpers/test_constants';

describe('CreditCardValidationRequiredAlert', () => {
  let wrapper;

  const createComponent = () => {
    return shallowMount(CreditCardValidationRequiredAlert, {
      stubs: {
        GlSprintf,
      },
    });
  };

  const findGlAlert = () => wrapper.findComponent(GlAlert);

  beforeEach(() => {
    window.gon = {
      subscriptions_url: TEST_HOST,
      payment_form_url: TEST_HOST,
    };

    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders title', () => {
    expect(findGlAlert().attributes('title')).toBe('User Verification Required');
  });

  it('renders description', () => {
    expect(findGlAlert().text()).toContain('As a user on a free or trial namespace');
  });

  it('renders danger alert', () => {
    expect(findGlAlert().attributes('variant')).toBe('danger');
  });

  describe('on success', () => {
    beforeEach(() => {
      wrapper.findComponent(AccountVerificationModal).vm.$emit('success');
    });

    it('renders the success alert instead of danger', () => {
      expect(findGlAlert().attributes('variant')).toBe('success');
    });
  });
});
