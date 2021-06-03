<script>
import { GlAlert, GlSprintf } from '@gitlab/ui';
import { s__, __, sprintf } from '~/locale';

const i18n = {
  title: s__('Admin|Quarterly reconcilliation will occur on %{qrtlyDate}'),
  description: s__(`Admin|The number of maximum users for your instance
is currently exceeding the number of users in license.
On %{qrtlyDate}, GitLab will process a quarterly reconciliation
and automatically bill you a prorated amount for the overage.
There is no action needed from you. If you have a credit card on file,
it will be charged. Otherwise, you will receive an invoice.`),
  learnMore: s__('Admin|Learn more about quarterly reconcilliation'),
  contactSupport: __('Contact support'),
};

const CONTACT_SUPPORT_URL = 'https://about.gitlab.com/support/#contact-support';

export default {
  name: 'QrtlyReconciliationAlert',
  components: {
    GlAlert,
    GlSprintf,
  },
  props: {
    date: {
      type: Date,
      required: true,
    },
  },
  computed: {
    alertTitle() {
      return sprintf(this.$options.i18n.title, { qrtlyDate: this.date });
    },
  },
  i18n,
  CONTACT_SUPPORT_URL,
};
</script>

<template>
  <gl-alert
    data-testid="qrtly-reconciliation-alert"
    variant="info"
    :title="alertTitle"
    :primary-button-text="$options.i18n.learnMore"
    :secondary-button-text="$options.i18n.contactSupport"
    :secondary-button-link="$options.CONTACT_SUPPORT_URL"
  >
    <gl-sprintf :message="$options.i18n.description">
      <template #qrtlyDate>
        <span>{{ date }}</span>
      </template>
    </gl-sprintf>
  </gl-alert>
</template>
