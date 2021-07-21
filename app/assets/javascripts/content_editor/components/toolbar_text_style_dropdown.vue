<script>
import { GlDropdown, GlDropdownItem, GlTooltipDirective as GlTooltip } from '@gitlab/ui';
import toolbarControlMixin from '~/content_editor/mixins/toolbar_control_mixin';
import { __ } from '~/locale';
import { TEXT_STYLE_DROPDOWN_ITEMS } from '../constants';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  directives: {
    GlTooltip,
  },
  mixins: [toolbarControlMixin],
  data() {
    return {
      activeItem: null,
    };
  },
  computed: {
    activeItemLabel() {
      const { activeItem } = this;

      return activeItem ? activeItem.label : this.$options.i18n.placeholder;
    },
  },
  onTiptapSelectionUpdate({ editor }) {
    this.updateActiveItem(editor);
  },
  onTiptapDocUpdate({ editor }) {
    this.updateActiveItem(editor);
  },
  methods: {
    updateActiveItem(editor) {
      this.activeItem = TEXT_STYLE_DROPDOWN_ITEMS.find((item) =>
        editor.isActive(item.contentType, item.commandParams),
      );
    },
    execute(item) {
      const { editorCommand, contentType, commandParams } = item;
      const value = commandParams?.level;

      if (editorCommand) {
        this.tiptapEditor
          .chain()
          [editorCommand](commandParams || {})
          .focus()
          .run();
      }

      this.$emit('execute', { contentType, value });
    },
    isActive(item) {
      return this.tiptapEditor.isActive(item.contentType, item.commandParams);
    },
  },
  items: TEXT_STYLE_DROPDOWN_ITEMS,
  i18n: {
    placeholder: __('Text style'),
  },
};
</script>
<template>
  <gl-dropdown
    v-gl-tooltip="$options.i18n.placeholder"
    size="small"
    :disabled="!activeItem"
    :text="activeItemLabel"
  >
    <gl-dropdown-item
      v-for="(item, index) in $options.items"
      :key="index"
      is-check-item
      :is-checked="isActive(item)"
      @click="execute(item)"
    >
      {{ item.label }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
