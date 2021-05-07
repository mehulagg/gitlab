<script>
import { GlAlert, GlLoadingIcon, GlModal, GlSprintf } from '@gitlab/ui';
import { s__, __ } from '~/locale';

const IFRAME_QUERY = 'enable_submit=false&pp=disable';
// 450 is the mininum required height to get all iframe inputs visible
const IFRAME_MINIMUM_HEIGHT = 450;
const i18n = Object.freeze({
  title: s__('Billings|Verify User Account'),
  description: s__(`
Billings|Your user account has been flagged for potential abuse for running a large number of concurrent pipelines.
To continue to run a large number of concurrent pipelines, you'll need to validate your account with a credit card.
%{strongStart}GitLab will not charge your credit card, it will only be used for validation.%{strongEnd}`),
  iframeNotSupported: __('Your browser does not support iFrames'),
  actions: {
    primary: {
      text: s__('Billings|Verify account'),
    },
  },
});

export default {
  components: {
    GlAlert,
    GlLoadingIcon,
    GlModal,
    GlSprintf,
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
  data() {
    return {
      error: null,
      isLoading: true,
    };
  },
  computed: {
    iframeSrc() {
      return `${this.iframeUrl}?${IFRAME_QUERY}`;
    },
    iframeHeight() {
      return IFRAME_MINIMUM_HEIGHT * window.devicePixelRatio;
    },
  },
  destroyed() {
    window.removeEventListener('message', this.handleFrameMessages, true);
  },
  methods: {
    submit(e) {
      e.preventDefault();

      this.error = null;
      this.isLoading = true;

      this.$refs.zuora.contentWindow.postMessage('submit', this.allowedOrigin);
    },
    show() {
      this.isLoading = true;
      this.$refs.modal.show();
    },
    handleFrameLoaded() {
      this.isLoading = false;
      window.addEventListener('message', this.handleFrameMessages, true);
    },
    handleFrameMessages(event) {
      if (!this.isEventAllowedForOrigin(event)) {
        return;
      }

      this.error = event.data;
      this.isLoading = false;
    },
    isEventAllowedForOrigin(event) {
      try {
        const url = new URL(event.origin);

        return url.origin === this.allowedOrigin;
      } catch {
        return false;
      }
    },
  },
  i18n,
};
</script>

<template>
  <gl-modal
    ref="modal"
    modal-id="credit-card-verification-modal"
    :title="$options.i18n.title"
    :action-primary="$options.i18n.actions.primary"
    @primary="submit"
  >
    <p>
      <gl-sprintf :message="$options.i18n.description">
        <template #strong="{ content }"
          ><strong>{{ content }}</strong></template
        >
      </gl-sprintf>
    </p>

    <gl-alert v-if="error" variant="danger">{{ error.msg }}</gl-alert>
    <gl-loading-icon v-if="isLoading" size="lg" />
    <!-- eslint-disable @gitlab/vue-require-i18n-strings -->
    <iframe
      v-show="!isLoading"
      id="zuora"
      :src="iframeSrc"
      style="border: none"
      width="100%"
      :height="iframeHeight"
      @load="handleFrameLoaded"
    >
      <p>{{ $options.i18n.iframeNotSupported }}</p>
    </iframe>
    <!-- eslint-enable @gitlab/vue-require-i18n-strings -->
  </gl-modal>
</template>
