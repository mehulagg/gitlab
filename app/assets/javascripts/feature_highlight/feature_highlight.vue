<script>
import {
  GlPopover,
  GlSprintf,
  GlLink,
  GlButton,
  GlSafeHtmlDirective as SafeHtml,
} from '@gitlab/ui';
import clusterPopover from '@gitlab/svgs/dist/illustrations/cluster_popover.svg';
import { dismiss } from './feature_highlight_helper';

export default {
  components: {
    GlPopover,
    GlSprintf,
    GlLink,
    GlButton,
  },
  directives: {
    SafeHtml,
  },
  props: {
    autoDevopsHelpPath: {
      type: String,
      required: true,
    },
    highlightId: {
      type: String,
      required: true,
    },
    dismissEndpoint: {
      type: String,
      required: true,
    }
  },
  data() {
    return {
      dismissed: false,
      triggerHidden: false,
    }
  },
  methods: {
    async dismiss() {
      dismiss(this.dismissEndpoint, this.highlightId);
      this.$refs.popover.$emit('close');
      this.dismissed = true;
    },
    hideTrigger() {
      if(this.dismissed) {
        this.triggerHidden = true;
      }
    }
  },
  clusterPopover,
  targetId: 'feature-highlight-trigger',
};
</script>
<template>
  <span class="gl-ml-3">
    <span v-if="!triggerHidden" id="feature-highlight-trigger" class="feature-highlight"></span>
    <gl-popover
      ref="popover"
      target="feature-highlight-trigger"
      :css-classes="['feature-highlight-popover']"
      triggers="hover"
      container="body"
      placement="right"
      boundary="viewport"
      @hidden="hideTrigger"
    >
      <!-- eslint-disable-next-line @gitlab/vue-require-i18n-attribute-strings -->
      <span v-safe-html="$options.clusterPopover" class="feature-highlight-illustration gl-display-flex gl-justify-content-center gl-py-4 gl-mb-4 gl-w-full"></span>
      <p>
        {{ __('Allows you to add and manage Kubernetes clusters.') }}
      </p>
      <p>
        <gl-sprintf
          :message="
            __(
              'Protip: %{linkStart}Auto DevOps%{linkEnd} uses Kubernetes clusters to deploy your code!',
            )
          "
        >
          <template #link="{ content }">
            <gl-link class="gl-font-sm" :href="autoDevopsHelpPath">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </p>
      <hr />
      <gl-button size="small" icon="thumb-up" variant="success" @click="dismiss">
        {{ __('Got it!') }}
      </gl-button>
    </gl-popover>
  </span>
</template>
