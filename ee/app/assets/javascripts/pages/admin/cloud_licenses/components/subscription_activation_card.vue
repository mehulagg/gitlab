<script>
import { GlAlert, GlCard, GlLink, GlSprintf } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';
import {
  activateSubscription,
  CONNECTIVITY_ERROR,
  connectivityErrorAlert,
  connectivityIssue,
  howToActivateSubscription,
} from '../constants';
import SubscriptionActivationForm from './subscription_activation_form.vue';

export const adminLicenseUrl = helpPagePath('/user/admin_area/license');
export const troubleshootingHelpLink = helpPagePath('user/admin_area/license.html#troubleshooting');
export const subscriptionActivationHelpLink = helpPagePath('user/admin_area/license.html');

export default {
  name: 'SubscriptionActivationCard',
  i18n: {
    activateSubscription,
    connectivityIssueTitle: connectivityIssue,
    connectivityIssueSubtitle: connectivityErrorAlert.subtitle,
    connectivityIssueHelpText: connectivityErrorAlert.helpText,
    howToActivateSubscription,
  },
  links: {
    adminLicenseUrl,
    subscriptionActivationHelpLink,
    troubleshootingHelpLink,
  },
  components: {
    GlAlert,
    GlCard,
    GlLink,
    GlSprintf,
    SubscriptionActivationForm,
  },
  data() {
    return {
      error: null,
    };
  },
  computed: {
    hasConnectivityIssue() {
      return this.error === CONNECTIVITY_ERROR;
    },
  },
  methods: {
    handleFormActivationFailure(error) {
      this.error = error;
    },
  },
};
</script>

<template>
  <gl-card body-class="gl-p-0">
    <template #header>
      <h5 class="gl-my-0 gl-font-weight-bold">
        {{ $options.i18n.activateSubscription }}
      </h5>
    </template>
    <div
      v-if="hasConnectivityIssue"
      class="gl-p-5 gl-border-b-1 gl-border-gray-100 gl-border-b-solid"
    >
      <gl-alert variant="danger" :title="$options.i18n.connectivityIssueTitle" :dismissible="false">
        <gl-sprintf :message="$options.i18n.connectivityIssueSubtitle">
          <template #link="{ content }">
            <gl-link
              :href="$options.links.subscriptionActivationHelpLink"
              target="_blank"
              class="gl-text-decoration-none!"
              >{{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
        <gl-sprintf :message="$options.i18n.connectivityIssueHelpText">
          <template #link="{ content }">
            <gl-link
              :href="$options.links.troubleshootingHelpLink"
              target="_blank"
              class="gl-text-decoration-none!"
              >{{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </gl-alert>
    </div>
    <p class="gl-mb-0 gl-px-5 gl-pt-5">
      <gl-sprintf :message="$options.i18n.howToActivateSubscription">
        <template #link="{ content }">
          <gl-link :href="$options.links.adminLicenseUrl" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </p>
    <subscription-activation-form
      class="gl-p-5"
      @subscription-activation-failure="handleFormActivationFailure"
    />
  </gl-card>
</template>
