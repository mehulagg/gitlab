<script>
import { GlMarkdown } from '@gitlab/ui';
import { EditorContent } from 'tiptap';
import TopToolbar from './top_toolbar.vue';

export default {
  components: {
    EditorContent,
    TopToolbar,
    GlMarkdown,
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
  <div class="gl-display-flex gl-flex-direction-column">
    <top-toolbar class="gl-mb-3" :editor="editor" />
    <gl-markdown compact>
      <editor-content :editor="editor" />
    </gl-markdown>
  </div>
</template>
