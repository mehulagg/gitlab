<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';
import {
  CONNECTIVITY_ERROR,
  connectivityErrorAlert,
  connectivityIssue,
  generalActivationError,
  howToActivateSubscription,
} from '../constants';

export const troubleshootingHelpLink = helpPagePath('user/admin_area/license.html', {
  anchor: 'troubleshooting',
});
export const subscriptionActivationHelpLink = helpPagePath('user/admin_area/license.html');

export default {
  name: 'SubscriptionActivationErrors',
  i18n: {
    connectivityIssueTitle: connectivityIssue,
    connectivityIssueSubtitle: connectivityErrorAlert.subtitle,
    connectivityIssueHelpText: connectivityErrorAlert.helpText,
    generalActivationError,
    howToActivateSubscription,
  },
  links: {
    subscriptionActivationHelpLink,
    troubleshootingHelpLink,
  },
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
  },
  props: {
    error: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    hasConnectivityIssue() {
      return this.error === CONNECTIVITY_ERROR;
    },
    hasGeneralError() {
      return this.error && !this.hasConnectivityIssue;
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="hasConnectivityIssue"
      variant="danger"
      :title="$options.i18n.connectivityIssueTitle"
      :dismissible="false"
      data-testid="connectivity-error-alert"
    >
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
    <gl-alert
      v-if="hasGeneralError"
      variant="danger"
      :title="$options.i18n.generalActivationError"
      :dismissible="false"
      data-testid="general-error-alert"
    >
      <gl-sprintf :message="$options.i18n.howToActivateSubscription">
        <template #link="{ content }">
          <gl-link :href="$options.links.adminLicenseUrl" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>
  </div>
</template>
