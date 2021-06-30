<script>
import { GlBanner, GlLink, GlSprintf } from '@gitlab/ui';
import {
  activateCloudLicense,
  subscriptionBannerText,
  subscriptionBannerTitle,
} from '../constants';

export const ACTIVATE_SUBSCRIPTION_EVENT = 'activate-subscription';

export default {
  name: 'SubscriptionActivationBanner',
  i18n: {
    bannerText: subscriptionBannerText,
    buttonText: activateCloudLicense,
    title: subscriptionBannerTitle,
  },
  components: {
    GlBanner,
    GlLink,
    GlSprintf,
  },
  inject: ['congratulationSvgPath', 'customersPortalUrl'],
  methods: {
    handlePrimary() {
      this.$emit(ACTIVATE_SUBSCRIPTION_EVENT);
    },
  },
};
</script>

<template>
  <gl-banner
    :button-text="$options.i18n.buttonText"
    :title="$options.i18n.title"
    variant="promotion"
    :svg-path="congratulationSvgPath"
    @primary="handlePrimary"
  >
    <p>
      <gl-sprintf :message="$options.i18n.bannerText">
        <template #blogPostLink="{ content }">
          <gl-link href="#" target="_blank">{{ content }}</gl-link>
        </template>
        <template #portalLink="{ content }">
          <gl-link :href="customersPortalUrl" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </p>
  </gl-banner>
</template>
