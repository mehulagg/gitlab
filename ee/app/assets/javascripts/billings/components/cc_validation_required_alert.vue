<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import AccountVerificationModal from './account_verification_modal.vue';

const i18n = {
  alertTitle: s__('Billings|User Verification Required'),
  alertText: s__(`Billings|As a user on a free or trial namespace, you'll need to verify your account with a credit card to run pipelines. This is required to help prevent
cryptomining attacks on GitLab infrastructure.
%{strongStart}GitLab will not charge or store your credit card, it will only be used for validation.%{strongEnd} %{linkStart}Learn more%{linkEnd}.`),
  primaryButtonText: s__('Billings|Verify account'),
};

export default {
  name: 'CreditCardValidationRequiredAlert',
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
    AccountVerificationModal,
  },
  props: {
    iframeUrl: {
      type: String,
      required: true,
    },
    allowedOrigin: {
      type: String,
      required: true,
    },
  },
  computed: {
    learnMoreUrl() {
      return 'about:blank';
    },
  },
  methods: {
    showModal() {
      this.$refs.modal.show();
    },
  },
  i18n,
};
</script>

<template>
  <div class="gl-pt-5">
    <gl-alert
      variant="danger"
      :dismissible="false"
      :title="$options.i18n.alertTitle"
      :primary-button-text="$options.i18n.primaryButtonText"
      @primaryAction="showModal"
    >
      <gl-sprintf :message="$options.i18n.alertText">
        <template #strong="{ content }">
          <strong>{{ content }}</strong>
        </template>
        <template #link="{ content }">
          <gl-link :href="learnMoreUrl">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>

    <account-verification-modal
      ref="modal"
      :iframe-url="iframeUrl"
      :allowed-origin="allowedOrigin"
    />
  </div>
</template>
