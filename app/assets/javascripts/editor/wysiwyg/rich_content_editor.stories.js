import { documentedStoriesOf } from '../../../documentation/documented_stories';
import { fromMarkdown, toMarkdown } from './markdown';
import * as gfmEditor from './editor/gfm_editor';
import RichContentEditor from './rich_content_editor.vue';

import * as frontmatter from './markdown/plugins/frontmatter';
import FrontmatterCodeBlock from './editor/plugins/frontmatter';

const TEST_CONTENT = `---
title: Page title
layout: /layouts/base.html
---

# Header 1

Paragraph number 1

## Header 2

Paragraph number 2

### Header 3

Paragraph number 3
`;

documentedStoriesOf('editor|Rich Content Editor', '')
  .add('default', () => ({
    components: {
      RichContentEditor,
    },
    template: '<rich-content-editor />',
  }))
  .add('default', () => ({
    components: {
      RichContentEditor,
    },
    data() {
      return {
        editor: null,
        content: TEST_CONTENT,
        selection: '',
        currentTab: 0,
      };
    },
    template: `
    <gl-tabs :value="currentTab" @input="syncContent">
      <gl-tab title="Editor">
        <rich-content-editor v-if="editor" :editor="editor" ref="wysiwyg" class="gl-mr-2" />
      </gl-tab>
      <gl-tab title="Source">
        <gl-form-textarea ref="markdown" rows="20" v-model="content" class="gl-h-full!" />
      </gl-tab>
    </gl-tabs>
    `,
    mounted() {
      this.editor = gfmEditor.build([new FrontmatterCodeBlock()]);

      this.editor.setContent(this.fromMarkdown());
    },
    methods: {
      async syncContent(selectedTab) {
        if (selectedTab === this.currentTab) {
          return;
        }

        this.currentTab = selectedTab;

        if (selectedTab === 0) {
          this.editor.setContent(this.fromMarkdown());
        } else {
          this.content = this.toMarkdown();
          const { selection } = this.editor;

          await this.$nextTick();

          const $textarea = this.$refs.markdown.$el;

          $textarea.focus();
          $textarea.setSelectionRange(selection.from, selection.to);
        }
      },
      fromMarkdown() {
        return fromMarkdown({
          schema: this.editor.schema,
          markdown: this.content,
          plugins: [[frontmatter.parse]],
          mappers: {
            ...frontmatter.mapper,
          },
        });
      },
      toMarkdown() {
        return toMarkdown({
          content: this.editor.state.doc,
          nodes: {
            frontmatter: frontmatter.serialize,
          },
        });
      },
    },
  }));
