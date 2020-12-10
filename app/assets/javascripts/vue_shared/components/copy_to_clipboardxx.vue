<script>
import { GlTruncate, GlButton, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  i18n: {
    issueEmail: __('Issue email'),
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlTruncate,
    GlButton,
  },
  props: {
    text: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div class="gl-flex align-items-center">
    <span>{{ $options.i18n.issueEmail }}:</span>
    <gl-truncate
      :text="
        'src/thisIs/AVeryLongFilePath/that/needs/to/be/smartly/truncated/from/the/middle/so/we/dont/lose/important/information/here.vue'
      "
    />
    <gl-button
      v-gl-tooltip.hover
      :title="s__('Copy email')"
      class="gl-border-none"
      data-clipboard-text="xxx"
      :data-clipboard-target="'#xxx'"
      id="xxx"
      icon="copy-to-clipboard"
    />
  </div>
</template>
