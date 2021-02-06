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
import { POPOVER_TARGET_ID } from './constants';

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
    },
  },
  data() {
    return {
      dismissed: false,
      triggerHidden: false,
    };
  },
  methods: {
    async dismiss() {
      dismiss(this.dismissEndpoint, this.highlightId);
      this.$refs.popover.$emit('close');
      this.dismissed = true;
    },
    hideTrigger() {
      if (this.dismissed) {
        this.triggerHidden = true;
      }
    },
  },
  clusterPopover,
  targetId: POPOVER_TARGET_ID,
};
</script>
<template>
  <span class="gl-ml-3">
    <span v-if="!triggerHidden" :id="$options.targetId" class="feature-highlight"></span>
    <gl-popover
      ref="popover"
      :target="$options.targetId"
      :css-classes="['feature-highlight-popover']"
      triggers="hover"
      container="body"
      placement="right"
      boundary="viewport"
      @hidden="hideTrigger"
    >
      <!-- eslint-disable-next-line @gitlab/vue-require-i18n-attribute-strings -->
      <span
        v-safe-html="$options.clusterPopover"
        class="feature-highlight-illustration gl-display-flex gl-justify-content-center gl-py-4 gl-w-full"
      ></span>
      <div class="gl-px-4 gl-py-5">
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
      </div>
    </gl-popover>
  </span>
</template>
