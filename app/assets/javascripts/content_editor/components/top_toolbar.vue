<script>
import ToolbarButton from './toolbar_button.vue';

export default {
  components: {
    ToolbarButton,
  },
  props: {
    editor: {
      type: Object,
      required: true,
    },
  },
};
</script>
<template>
  <div>
    <toolbar-button content-type="bold" icon-name="bold" label="Bold" :editor="editor" />
    <toolbar-button content-type="italic" icon-name="italic" label="Italic" :editor="editor" />
    <toolbar-button content-type="code" icon-name="code" label="Code" :editor="editor" />
    <span class="gl-mr-3"></span>
    <toolbar-button content-type="blockquote" icon-name="quote" label="Quote" :editor="editor" />
  </div>
</template>
