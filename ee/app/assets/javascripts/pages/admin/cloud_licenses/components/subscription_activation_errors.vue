<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';
import {
  CONNECTIVITY_ERROR,
  connectivityErrorAlert,
  connectivityIssue,
  generalActivationError,
  howToActivateSubscription,
  INVALID_CODE,
  invalidActivationCode,
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
    invalidActivationCode,
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
    hasConnectivityIssueError() {
      return this.error === CONNECTIVITY_ERROR;
    },
    hasInvalidCodeError() {
      return this.error === INVALID_CODE;
    },
    hasGeneralError() {
      return this.error && !this.hasConnectivityIssueError;
    },
    secondaryAlertBody() {
      return this.hasInvalidCodeError
        ? this.$options.i18n.invalidActivationCode
        : howToActivateSubscription;
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="hasConnectivityIssueError"
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
      <gl-sprintf :message="secondaryAlertBody">
        <template #link="{ content }">
          <gl-link :href="$options.links.subscriptionActivationHelpLink" target="_blank">{{
            content
          }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>
  </div>
</template>
