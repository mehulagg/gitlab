import { GlAlert, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CreditCardValidationRequiredAlert from 'ee/billings/components/cc_validation_required_alert.vue';

describe('CreditCardValidationRequiredAlert', () => {
  let wrapper;

  const createComponent = () => {
    return shallowMount(CreditCardValidationRequiredAlert, {
      propsData: {
        iframeUrl: 'about:blank',
        allowedOrigin: 'about:blank',
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders title', () => {
    expect(wrapper.findComponent(GlAlert).attributes('title')).toBe('User Verification Required');
  });

  it('renders description', () => {
    expect(wrapper.findComponent(GlAlert).text()).toContain(
      'As a user on a free or trial namespace',
    );
  });
});
