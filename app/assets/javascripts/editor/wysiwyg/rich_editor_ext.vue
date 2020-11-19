<script>
import RichContentEditor from '~/editor/wysiwyg/rich_content_editor.vue';
import * as gfmEditor from '~/editor/wysiwyg/editor/gfm_editor';
import FrontmatterCodeBlock from '~/editor/wysiwyg/editor/plugins/frontmatter';
import { fromMarkdown, toMarkdown } from '~/editor/wysiwyg/markdown';
import * as frontmatter from '~/editor/wysiwyg/markdown/plugins/frontmatter';

export default {
  components: {
    RichContentEditor,
  },
  data() {
    return {
      editor: null,
    };
  },
  inject: ['instance'],
  created() {
    this.editor = gfmEditor.build({
      extensions: [new FrontmatterCodeBlock()],
      onFocus: () => {
        this.editor.setContent(this.updatedWysiwyg());
      },
      onBlur: () => {
        this.instance.setValue(this.updatedMarkdown());
      },
    });
  },
  mounted() {
    this.editor.setContent(this.updatedWysiwyg(this.instance.getValue()));
  },
  methods: {
    updatedWysiwyg() {
      return fromMarkdown({
        schema: this.editor.schema,
        markdown: this.instance.getValue(),
        plugins: [[frontmatter.parse]],
        mappers: {
          ...frontmatter.mapper,
        },
      });
    },
    updatedMarkdown() {
      return toMarkdown({
        content: this.editor.state.doc,
        nodes: {
          frontmatter: frontmatter.serialize,
        },
      });
    },
  },
};
</script>
<template>
  <rich-content-editor v-if="editor" ref="wysiwyg" :editor="editor" class="gl-w-full gl-h-full" />
</template>
