<script>
import { GlModal, GlLink, GlIcon, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import trialLicenseActivatedSvg from 'ee_icons/_ee_trial_license_activated.svg';
import csrf from '~/lib/utils/csrf';
import { __ } from '~/locale';

export default {
  name: 'UploadTrialLicenseModal',
  components: {
    GlModal,
    GlLink,
    GlIcon,
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
  },
  csrf,
  cancelOptions: {
    text: __('Cancel'),
  },
  primaryOptions: {
    text: __('Install license'),
    attributes: [
      {
        variant: 'confirm',
        category: 'primary',
      },
    ],
  },
  trialLicenseActivatedSvg,
};
</script>

<template>
  <gl-modal
    ref="modal"
    :visible="visible"
    modal-id="modal-upload-trial-license"
    body-class="modal-upload-trial-license"
    :action-primary="$options.primaryOptions"
    :action-cancel="$options.cancelOptions"
    @primary.prevent="submitForm"
  >
    <div class="trial-activated-graphic gl-display-flex gl-justify-content-center gl-mt-5">
      <span v-safe-html="$options.trialLicenseActivatedSvg" class="svg-container"></span>
    </div>
    <h3 class="gl-text-center">{{ __('Your trial license was issued!') }}</h3>
    <p class="gl-text-center gl-text-gray-500 mw-70p m-auto gl-font-size-h2 gl-line-height-28">
      {{
        __(
          'Your trial license was issued and activated. Install it to enjoy GitLab Ultimate for 30 days.',
        )
      }}
    </p>
    <form
      id="new_license"
      ref="form"
      :action="adminLicensePath"
      enctype="multipart/form-data"
      method="post"
    >
      <div class="gl-mt-5">
        <gl-link
          id="hide-license"
          href="#hide-license"
          class="hide-license gl-text-gray-600 gl-text-center"
          >{{ __('Show license key') }}<gl-icon name="chevron-down"
        /></gl-link>
        <gl-link
          id="show-license"
          href="#show-license"
          class="show-license gl-text-gray-600 gl-text-center"
          >{{ __('Hide license key') }}<gl-icon name="chevron-up"
        /></gl-link>
        <div class="card trial-license-preview gl-overflow-y-auto gl-word-break-all gl-mt-5">
          {{ licenseKey }}
        </div>
      </div>
      <input :value="$options.csrf.token" type="hidden" name="authenticity_token" />
      <input id="license_data" :value="licenseKey" type="hidden" name="license[data]" />
    </form>
  </gl-modal>
</template>
