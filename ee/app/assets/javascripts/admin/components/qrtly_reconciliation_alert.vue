<script>
import { GlAlert, GlSprintf } from '@gitlab/ui';
import Cookie from 'js-cookie';
import { helpPagePath } from '~/helpers/help_page_helper';
import { formatDate, getDayDifference } from '~/lib/utils/datetime_utility';
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

const qrtlyReconciliationHelpPageUrl = helpPagePath('subscriptions/self_managed/index', {
  anchor: 'quarterly-subscription-reconciliation',
});

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
    cookieKey: {
      type: String,
      required: true,
    },
  },
  computed: {
    alertTitle() {
      return sprintf(this.$options.i18n.title, { qrtlyDate: this.formattedDate });
    },
    formattedDate() {
      return formatDate(this.date, 'isoDate');
    },
  },
  methods: {
    handleDismiss() {
      Cookie.set(this.cookieKey, true, {
        expires: getDayDifference(new Date(), new Date(this.date)),
      });
    },
  },
  i18n,
  CONTACT_SUPPORT_URL,
  qrtlyReconciliationHelpPageUrl,
};
</script>

<template>
  <gl-alert
    data-testid="qrtly-reconciliation-alert"
    variant="info"
    :title="alertTitle"
    :primary-button-text="$options.i18n.learnMore"
    :primary-button-link="$options.qrtlyReconciliationHelpPageUrl"
    :secondary-button-text="$options.i18n.contactSupport"
    :secondary-button-link="$options.CONTACT_SUPPORT_URL"
    @dismiss="handleDismiss"
  >
    <gl-sprintf :message="$options.i18n.description">
      <template #qrtlyDate>
        <span>{{ formattedDate }}</span>
      </template>
    </gl-sprintf>
  </gl-alert>
</template>
