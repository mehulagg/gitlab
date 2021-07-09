import { GlBanner } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { setCookie, getCookie, removeCookie } from '~/lib/utils/common_utils';
import TerraformNotification from '~/projects/terraform_notification/components/terraform_notification.vue';

describe('TerraformNotificationBanner', () => {
  let wrapper;

  const provideData = {
    projectId: 1,
    docsUrl: 'path/to/docs/url',
  };
  const getCookieName = () => wrapper.vm.bannerDissmisedKey;
  const findBanner = () => wrapper.findComponent(GlBanner);

  beforeEach(() => {
    wrapper = shallowMountExtended(TerraformNotification, {
      stubs: { GlBanner },
      provide: provideData,
    });
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  it('should correctly compute bannerDissmisedKey property', () => {
    expect(wrapper.vm.bannerDissmisedKey).toBe(getCookieName());
  });

  describe('when the dismiss cookie is set', () => {
    beforeEach(() => {
      setCookie(getCookieName(), true);
      wrapper = shallowMountExtended(TerraformNotification, {
        provide: provideData,
      });
    });

    it('should set isVisible property to false', () => {
      expect(wrapper.vm.isVisible).toBe(false);
    });

    it('should not render the banner', () => {
      expect(findBanner().exists()).toBe(false);
    });

    afterEach(() => {
      removeCookie(getCookieName());
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
