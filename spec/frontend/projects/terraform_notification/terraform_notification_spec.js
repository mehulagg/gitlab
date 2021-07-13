import { GlBanner } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { setCookie, getCookie, removeCookie } from '~/lib/utils/common_utils';
import TerraformNotification from '~/projects/terraform_notification/components/terraform_notification.vue';

describe('TerraformNotificationBanner', () => {
  let wrapper;

  const propsData = {
    projectId: 1,
  };
  const getCookieName = () => wrapper.vm.bannerDissmisedKey;
  const findBanner = () => wrapper.findComponent(GlBanner);

  beforeEach(() => {
    wrapper = shallowMount(TerraformNotification, {
      propsData,
      stubs: { GlBanner },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    removeCookie(getCookieName());
  });

  describe('when the dismiss cookie is set', () => {
    beforeEach(() => {
      setCookie(getCookieName(), true);
      wrapper = shallowMount(TerraformNotification, {
        propsData,
      });
    });

    it('should set isVisible property to false', () => {
      expect(wrapper.vm.isVisible).toBe(false);
    });

    it('should not render the banner', () => {
      expect(findBanner().exists()).toBe(false);
    });
  });

  describe('when the dismiss cookie is not set', () => {
    it('should render the banner', () => {
      expect(findBanner().exists()).toBe(true);
    });
  });

  describe('when close button is clicked', () => {
    beforeEach(async () => {
      await findBanner().vm.$emit('close');
    });

    it('should remove the banner and set the dismiss cookie', () => {
      expect(findBanner().exists()).toBe(false);
      expect(getCookie(getCookieName())).toBe('true');
    });
  });
});
