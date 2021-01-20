<script>
// NOTE: This is similar to recaptcha_modal.vue, but it directly uses the reCAPTCHA Javascript API
// (https://developers.google.com/recaptcha/docs/display#js_api) and gl-modal, rather than relying
// on the form-based ReCAPTCHA HTML being pre-rendered by the backend and using deprecated-modal.

import _ from 'lodash';
import { GlModal, GlModalDirective } from '@gitlab/ui';
import { initRecaptchaScript } from '~/captcha/init_recaptcha_script';

export default {
  name: 'NewRecaptchaModal',
  components: {
    GlModal,
  },
  directives: {
    'gl-modal': GlModalDirective,
  },
  props: {
    needsRecaptchaResponse: {
      type: Boolean,
      required: false,
      default: false,
    },
    recaptchaSiteKey: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      modalId: _.uniqueId('recaptcha-modal-'),
      showModal: false,
    };
  },
  watch: {
    needsRecaptchaResponse(newNeedsRecaptchaResponse) {
      // The needsRecaptchaResponse property controls the showing and hiding of the modal. If it's
      // true, the modal is shown. If it's not, the modal is hidden. This is independent of
      // retrieving the recaptchaResponse string via the reCAPTCHA API and emitting it
      // to the parent component via an event.
      this.showModal = newNeedsRecaptchaResponse;
    },
    showModal(newShowModal) {
      if (newShowModal) {
        this.$refs.modal.show();
      } else {
        this.$refs.modal.hide();
      }
    },
  },
  methods: {
    /**
     * Returns the recaptchaResponse by emitting
     * the 'receivedRecaptchaEvent' event.
     */
    emitReceivedRecaptchaResponse(recaptchaResponse) {
      this.$emit('receivedRecaptchaResponse', recaptchaResponse);
    },
    /**
     * default event emitted when modal is shown
     */
    shown() {
      const containerRef = this.$refs.gRecaptcha;
      initRecaptchaScript()
        .then(() => {
          window.grecaptcha.render(containerRef, {
            sitekey: this.recaptchaSiteKey,
            callback: this.emitReceivedRecaptchaResponse,
          });
        })
        .catch(() => {
          // TODO: flash the error or notify the user some other way
          this.hideModalWithNoRecaptchaResponse();
        });
      // this.appendRecaptchaScript();
    },
    hideModalWithNoRecaptchaResponse() {
      // TODO: Should this be handled via a separate error event rather than letting an
      //  empty recaptchaResponse represent a failure to obtain it?
      this.emitReceivedRecaptchaResponse('');
      this.showModal = false;
    },
    /**
     * default event emitted by modal's default header close button
     */
    close() {
      this.hideModalWithNoRecaptchaResponse();
    },
    /**
     * default event emitted by modal's default cancel button
     */
    cancel() {
      this.hideModalWithNoRecaptchaResponse();
    },
  },
};
</script>
<template>
  <div>
    <!-- Note: The action-cancel button isn't necessary for the functionality of the modal, but   -->
    <!-- there must be at least one button or focusable element, or the gl-modal fails to render. -->
    <!-- We could modify gl-model to remove this requirement.                                     -->
    <gl-modal
      ref="modal"
      :modal-id="modalId"
      :title="__('Please solve the reCAPTCHA')"
      :action-cancel="{ text: __('Cancel') }"
      @shown="shown"
      @close="close"
      @cancel="cancel"
    >
      <!-- TODO: Need to handle data-expired-callback and data-error-callback -->
      <div ref="gRecaptcha"></div>
      <p>{{ __('We want to be sure it is you, please confirm you are not a robot.') }}</p>
    </gl-modal>
  </div>
</template>
