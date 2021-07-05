<script>
import { GlModal, GlLink, GlIcon, GlButton, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import trialLicenseActivatedSvg from 'ee_icons/_ee_trial_license_activated.svg';
import csrf from '~/lib/utils/csrf';

export default {
  name: 'UploadTrialLicenseModal',
  components: {
    GlModal,
    GlLink,
    GlIcon,
    GlButton,
  },
  directives: {
    SafeHtml,
  },
  props: {
    licenseKey: {
      type: String,
      required: true,
    },
    adminLicensePath: {
      type: String,
      required: true,
    },
    initialShow: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  data() {
    return {
      visible: this.initialShow,
    };
  },
  methods: {
    submitForm() {
      this.$refs.form.submit();
    },
    closeModal() {
      this.$refs.modal.hide();
    },
  },
  csrf,
  trialLicenseActivatedSvg,
};
</script>

<template>
  <gl-modal
    ref="modal"
    :visible="visible"
    modal-id="modal-upload-trial-license"
    body-class="modal-upload-trial-license"
  >
    <div class="trial-activated-graphic gl-display-flex gl-justify-content-center gl-mt-5">
      <span v-safe-html="$options.trialLicenseActivatedSvg" class="svg-container"></span>
    </div>
    <h3 class="confirmation-title text-center">{{ __('Your trial license was issued!') }}</h3>
    <p class="confirmation-desc text-center text-secondary mw-70p m-auto lead">
      {{
        __(
          'Your trial license was issued and activated. Install it to enjoy GitLab Ultimate for 30 days.',
        )
      }}
    </p>
    <form
      ref="form"
      id="new_license"
      :action="adminLicensePath"
      enctype="multipart/form-data"
      method="post"
    >
      <div class="gl-mt-5">
        <gl-link
          id="hide-license"
          href="#hide-license"
          class="hide-license gl-text-gray-600 text-center"
          >{{ __('Show license key') }}<gl-icon name="chevron-down"
        /></gl-link>
        <gl-link
          href="#show-license"
          id="show-license"
          class="show-license gl-text-gray-600 text-center"
          >{{ __('Hide license key') }}<gl-icon name="chevron-up"
        /></gl-link>
        <div class="card trial-license-preview gl-overflow-y-auto gl-word-break-all gl-mt-5">
          {{ licenseKey }}
        </div>
      </div>
      <input :value="$options.csrf.token" type="hidden" name="authenticity_token" />
      <input :value="licenseKey" id="license_data" type="hidden" name="license[data]" />
    </form>
    <template #modal-footer>
      <gl-button @click="closeModal">
        {{ __('Cancel') }}
      </gl-button>
      <gl-button category="primary" variant="confirm" @click="submitForm">{{
        __('Install license')
      }}</gl-button>
    </template>
  </gl-modal>
</template>
