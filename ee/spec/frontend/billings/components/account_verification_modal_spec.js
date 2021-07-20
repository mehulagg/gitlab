import { GlLoadingIcon, GlModal, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AccountVerificationModal from 'ee/billings/components/account_verification_modal.vue';

describe('Account verification modal', () => {
  let wrapper;

  const createComponent = () => {
    return shallowMount(AccountVerificationModal, {
      propsData: {
        iframeUrl: 'https://gitlab.com',
        allowedOrigin: 'https://gitlab.com',
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('on destroying', () => {
    it('removes message event listener', () => {
      const removeEventListenerSpy = jest.spyOn(window, 'removeEventListener');
      wrapper = createComponent();

      wrapper.destroy();

      expect(removeEventListenerSpy).toHaveBeenCalledWith(
        'message',
        wrapper.vm.handleFrameMessages,
        true,
      );
    });
  });

  describe('on creation', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('is in the loading state', () => {
      expect(wrapper.findComponent(GlLoadingIcon).isVisible()).toBe(true);
    });

    it('renders the title', () => {
      expect(wrapper.findComponent(GlModal).attributes('title')).toBe('Validate user account');
    });

    it('renders the description', () => {
      expect(wrapper.find('p').text()).toContain('To use free pipeline minutes');
    });
  });
});
