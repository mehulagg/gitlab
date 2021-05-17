<script>
import { GlAlert, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import AccountVerificationModal from './account_verification_modal.vue';

const i18n = {
  successAlert: {
    title: s__('Billings|User successfully validated'),
    text: s__(
      'Billings|Your user account has been successfully validated. You can now use free pipeline minutes.',
    ),
  },
  dangerAlert: {
    title: s__('Billings|User validation required'),
    text: s__(`Billings|To use free pipeline minutes on shared runners, you’ll need to validate your account with a credit card. If you prefer not to provide a credit card, you can run pipelines by bringing your own runners and disabling shared runners for your project.
    This is required to discourage and reduce abuse on GitLab infrastructure.
%{strongStart}GitLab will not charge or store your credit card, it will only be used for validation.%{strongEnd}`),
    primaryButtonText: s__('Billings|Validate account'),
  },
};

export default {
  name: 'CreditCardValidationRequiredAlert',
  components: {
    GlAlert,
    GlSprintf,
    AccountVerificationModal,
  },
  data() {
    return {
      shouldRenderSuccess: false,
    };
  },
  computed: {
    iframeUrl() {
      return gon.payment_form_url;
    },
    allowedOrigin() {
      return gon.subscriptions_url;
    },
  },
  methods: {
    showModal() {
      this.$refs.modal.show();
    },
    handleSuccessfulVerification() {
      this.$refs.modal.hide();
      this.shouldRenderSuccess = true;
    },
  },
  i18n,
};
</script>

<template>
  <div data-testid="creditCardValidationRequiredAlert">
    <gl-alert
      v-if="shouldRenderSuccess"
      variant="success"
      :title="$options.i18n.successAlert.title"
      :dismissible="false"
    >
      {{ $options.i18n.successAlert.text }}
    </gl-alert>
    <gl-alert
      v-else
      variant="danger"
      :dismissible="false"
      :title="$options.i18n.dangerAlert.title"
      :primary-button-text="$options.i18n.dangerAlert.primaryButtonText"
      @primaryAction="showModal"
    >
      <gl-sprintf :message="$options.i18n.dangerAlert.text">
        <template #strong="{ content }">
          <strong>{{ content }}</strong>
        </template>
      </gl-sprintf>
    </gl-alert>

    <account-verification-modal
      ref="modal"
      :iframe-url="iframeUrl"
      :allowed-origin="allowedOrigin"
      @success="handleSuccessfulVerification"
    />
  </div>
</template>
