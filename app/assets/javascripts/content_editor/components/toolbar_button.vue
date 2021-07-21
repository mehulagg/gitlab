<script>
import { GlButton, GlTooltipDirective as GlTooltip } from '@gitlab/ui';
import toolbarControlMixin from '~/content_editor/mixins/toolbar_control_mixin';

export default {
  components: {
    GlButton,
  },
  directives: {
    GlTooltip,
  },
  mixins: [toolbarControlMixin],
  props: {
    iconName: {
      type: String,
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
    editorCommand: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      isActive: null,
    };
  },
  onTiptapSelectionUpdate({ editor }) {
    this.isActive = editor.isActive(this.contentType) && editor.isFocused;
  },
  methods: {
    execute() {
      const { contentType } = this;

      if (this.editorCommand) {
        this.tiptapEditor.chain()[this.editorCommand]().focus().run();
      }

      this.$emit('execute', { contentType });
    },
  },
};
</script>
<template>
  <gl-button
    v-gl-tooltip
    category="tertiary"
    size="small"
    class="gl-mx-2"
    :class="{ active: isActive }"
    :aria-label="label"
    :title="label"
    :icon="iconName"
    @click="execute"
  />
</template>
