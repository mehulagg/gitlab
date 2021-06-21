import { GlBanner, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SubscriptionActivationBanner, {
  ACTIVATE_SUBSCRIPTION_EVENT,
} from 'ee/admin/subscriptions/show/components/subscription_activation_banner.vue';
import {
  activateCloudLicense,
  subscriptionBannerText,
  subscriptionBannerTitle,
} from 'ee/admin/subscriptions/show/constants';

describe('SubscriptionActivationBanner', () => {
  let wrapper;

  const findBanner = () => wrapper.findComponent(GlBanner);
  const findLink = () => wrapper.findComponent(GlLink);

  const customersPortalUrl = 'customers.dot';
  const congratulationSvgPath = '/path/to/svg';
  const createComponent = () => {
    wrapper = shallowMount(SubscriptionActivationBanner, {
      provide: {
        congratulationSvgPath,
        customersPortalUrl,
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('provides the correct props to the banner', () => {
    expect(findBanner().props()).toMatchObject({
      buttonText: activateCloudLicense,
      title: subscriptionBannerTitle,
      svgPath: congratulationSvgPath,
    });
  });

  it('contains an help text', () => {
    expect(findBanner().text()).toMatchInterpolatedText(subscriptionBannerText);
  });

  it('contains a link to customers portal', () => {
    expect(findLink().attributes('href')).toBe(customersPortalUrl);
  });

  it('emits an event when the primary button is clicked', () => {
    findBanner().vm.$emit('primary');

    expect(wrapper.emitted(ACTIVATE_SUBSCRIPTION_EVENT)).toEqual([[]]);
  });
});
