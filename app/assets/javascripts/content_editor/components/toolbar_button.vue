<script>
import { GlButton, GlIcon, GlTooltipDirective as GlTooltip } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlIcon,
  },
  directives: {
    GlTooltip,
  },
  props: {
    iconName: {
      type: String,
      required: true,
    },
    editor: {
      type: Object,
      required: true,
    },
    contentType: {
      type: String,
      required: true,
    },
    label: {
      type: String,
      required: true,
    },
    executeCommand: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  computed: {
    isActive() {
      return this.editor.isActive[this.contentType]() && this.editor.focused;
    },
  },
  methods: {
    execute() {
      const { contentType } = this;

      if (this.executeCommand) {
        this.editor.commands[contentType]();
      }

      this.$emit('click', { contentType });
    },
  },
};
</script>
<template>
  <gl-button
    v-gl-tooltip
    category="tertiary"
    size="small"
    :class="{ active: isActive }"
    :aria-label="label"
    :title="label"
    @click="execute"
  >
    <gl-icon :name="iconName" :size="16" />
  </gl-button>
</template>
