import { GlLoadingIcon } from '@gitlab/ui';
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
      );
    });
  });

  describe('on creation', () => {
    it('is in the loading state', () => {
      wrapper = createComponent();

      expect(wrapper.findComponent(GlLoadingIcon).isVisible()).toBe(true);

      wrapper.destroy();
    });
  });
});
