<script>
import { GlAlert, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import AccountVerificationModal from './account_verification_modal.vue';

const i18n = {
  successAlert: {
    title: s__('Billings|User successfully verified'),
    text: s__(
      'Billings|Your user account has been successfully verified. You will now be able to run pipelines on any free or trial namespace.',
    ),
  },
  dangerAlert: {
    title: s__('Billings|User Verification Required'),
    text: s__(`Billings|As a user on a free or trial namespace, you'll need to verify your account with a credit card to run pipelines. This is required to help prevent
cryptomining attacks on GitLab infrastructure.
%{strongStart}GitLab will not charge or store your credit card, it will only be used for validation.%{strongEnd}`),
    primaryButtonText: s__('Billings|Verify account'),
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
