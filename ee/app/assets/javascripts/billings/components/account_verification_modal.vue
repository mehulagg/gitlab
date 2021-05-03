<script>
import { GlAlert, GlLoadingIcon, GlModal, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import { s__, __ } from '~/locale';

const IFRAME_QUERY = 'enable_submit=false&pp=disable';

const i18n = Object.freeze({
  title: s__('Billings|Verify User Account'),
  description: s__(`
Billings|Your user account has been flagged for potential abuse for running a large number of concurrent pipelines.
To continue to run a large number of concurrent pipelines, you'll need to validate your account with a credit card.
<strong>GitLab will not charge your credit card, it will only be used for validation.</strong>
`),
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
  },
  directives: {
    SafeHtml,
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
      // 450 is the mininum required height to get all iframe inputs visible
      return 450 * window.devicePixelRatio;
    },
  },
  destroyed() {
    window.removeEventListener('message', this.handleFrameMessages);
  },
  methods: {
    submit(e) {
      e.preventDefault();

      this.error = null;
      this.isLoading = true;

      this.$refs.zuora.contentWindow.postMessage('submit', this.allowedOrigin);
      window.addEventListener('message', this.handleFrameMessages, true);
    },
    show() {
      this.isLoading = true;
      this.$refs.modal.show();
    },
    handleFrameLoaded() {
      this.isLoading = false;
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

        return url === this.allowedOrigin;
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
    <p v-safe-html="$options.i18n.description"></p>

    <gl-alert v-if="error" variant="danger">{{ error.msg }}</gl-alert>
    <gl-loading-icon v-if="isLoading" size="lg" />
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
  </gl-modal>
</template>
