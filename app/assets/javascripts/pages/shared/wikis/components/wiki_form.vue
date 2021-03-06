<script>
/* eslint-disable vue/no-template-shadow */

import { GlForm, GlIcon, GlLink, GlButton, GlSprintf } from '@gitlab/ui';
import csrf from '~/lib/utils/csrf';
import { __, s__, sprintf } from '~/locale';
import MarkdownField from '~/vue_shared/components/markdown/field.vue';

export default {
  components: {
    GlForm,
    GlSprintf,
    GlIcon,
    GlLink,
    GlButton,
    MarkdownField,
  },
  props: {
    formatOptions: {
      type: Object,
      required: true,
    },
    pageInfo: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      title: this.pageInfo.title || '',
      format: this.pageInfo.format || 'markdown',
      content: this.pageInfo.content || '',
      commitMessage: '',
    };
  },
  computed: {
    csrfToken() {
      return csrf.token;
    },
    formAction() {
      return this.pageInfo.persisted ? this.pageInfo.path : this.pageInfo.createPath;
    },
    helpPath() {
      if (this.pageInfo.persisted) return `${this.pageInfo.helpPath}#moving-a-wiki-page`;
      return `${this.pageInfo.helpPath}#creating-a-new-wiki-page`;
    },
    commitMessageI18n() {
      return this.pageInfo.persisted
        ? s__('WikiPageCreate|Update %{pageTitle}')
        : s__('WikiPageEdit|Create %{pageTitle}');
    },
    linkExample() {
      switch (this.format) {
        case 'rdoc':
          return '{Link title}[link:page-slug]';
        case 'asciidoc':
          return 'link:page-slug[Link title]';
        case 'org':
          return '[[page-slug]]';
        default:
          return '[Link Title](page-slug)';
      }
    },
    submitButtonText() {
      if (this.pageInfo.persisted) return __('Save changes');
      return s__('Wiki|Create page');
    },
    cancelFormPath() {
      if (this.pageInfo.persisted) return this.pageInfo.path;
      return this.pageInfo.wikiPath;
    },
    hasTitle() {
      return this.title.trim();
    },
    hasContent() {
      return this.content.trim();
    },
    wikiSpecificMarkdownHelpPath() {
      return `${this.pageInfo.markdownHelpPath}#wiki-specific-markdown`;
    },
  },
  mounted() {
    this.updateCommitMessage();
  },
  methods: {
    handleFormSubmit() {
      window.onbeforeunload = null;
    },

    handleContentChange() {
      window.onbeforeunload = () => '';
    },

    updateCommitMessage() {
      if (!this.hasTitle) return;

      // Replace hyphens with spaces
      const newTitle = this.title.replace(/-+/g, ' ');

      const newCommitMessage = sprintf(this.commitMessageI18n, { pageTitle: newTitle }, false);
      this.commitMessage = newCommitMessage;
    },
  },
};
</script>

<template>
  <gl-form
    :action="formAction"
    method="post"
    class="wiki-form common-note-form gl-mt-3 js-quick-submit"
    @submit="handleFormSubmit"
  >
    <input :value="csrfToken" type="hidden" name="authenticity_token" />
    <input v-if="pageInfo.persisted" type="hidden" name="_method" value="put" />
    <input
      :v-if="pageInfo.persisted"
      type="hidden"
      name="wiki[last_commit_sha]"
      :value="pageInfo.lastCommitSha"
    />
    <div class="form-group row">
      <div class="col-sm-2 col-form-label">
        <label class="control-label-full-width" for="wiki_title">{{ s__('Wiki|Title') }}</label>
      </div>
      <div class="col-sm-10">
        <input
          id="wiki_title"
          v-model="title"
          name="wiki[title]"
          type="text"
          class="form-control qa-wiki-title-textbox"
          :required="true"
          :autofocus="!pageInfo.persisted"
          :placeholder="s__('Wiki|Page title')"
          @input="updateCommitMessage"
        />
        <span class="gl-display-inline-block gl-max-w-full gl-mt-2 gl-text-gray-600">
          <gl-icon class="gl-mr-n1" name="bulb" />
          {{
            pageInfo.persisted
              ? s__(
                  'WikiEditPageTip|Tip: You can move this page by adding the path to the beginning of the title.',
                )
              : s__(
                  'WikiNewPageTip|Tip: You can specify the full path for the new file. We will automatically create any missing directories.',
                )
          }}
          <gl-link :href="helpPath" target="_blank" data-testid="wiki-title-help-link"
            ><gl-icon name="question-o" /> {{ __('More Information.') }}</gl-link
          >
        </span>
      </div>
    </div>
    <div class="form-group row">
      <div class="col-sm-2 col-form-label">
        <label class="control-label-full-width" for="wiki_format">{{ s__('Wiki|Format') }}</label>
      </div>
      <div class="col-sm-10">
        <select id="wiki_format" v-model="format" class="form-control" name="wiki[format]">
          <option v-for="(key, label) of formatOptions" :key="key" :value="key">
            {{ label }}
          </option>
        </select>
      </div>
    </div>
    <div class="form-group row">
      <div class="col-sm-2 col-form-label">
        <label class="control-label-full-width" for="wiki_content">{{ s__('Wiki|Content') }}</label>
      </div>
      <div class="col-sm-10">
        <markdown-field
          :markdown-preview-path="pageInfo.markdownPreviewPath"
          :can-attach-file="true"
          :enable-autocomplete="true"
          :textarea-value="content"
          :markdown-docs-path="pageInfo.markdownHelpPath"
          :uploads-path="pageInfo.uploadsPath"
          class="bordered-box"
        >
          <template #textarea>
            <textarea
              id="wiki_content"
              ref="textarea"
              v-model="content"
              name="wiki[content]"
              class="note-textarea qa-wiki-content-textarea js-gfm-input js-autosize markdown-area"
              dir="auto"
              data-supports-quick-actions="false"
              data-qa-selector="note_textarea"
              :autofocus="pageInfo.persisted"
              :aria-label="s__('Wiki|Content')"
              :placeholder="s__('WikiPage|Write your content or drag files here…')"
              @input="handleContentChange"
            >
            </textarea>
          </template>
        </markdown-field>
        <div class="clearfix"></div>
        <div class="error-alert"></div>

        <div class="form-text gl-text-gray-600">
          <gl-sprintf
            :message="
              s__(
                'WikiMarkdownTip|To link to a (new) page, simply type %{linkExample}. More examples are in the %{linkStart}documentation%{linkEnd}.',
              )
            "
          >
            <template #linkExample
              ><code>{{ linkExample }}</code></template
            >
            <template #link="{ content }"
              ><gl-link
                :href="wikiSpecificMarkdownHelpPath"
                target="_blank"
                data-testid="wiki-markdown-help-link"
                >{{ content }}</gl-link
              ></template
            >
          </gl-sprintf>
        </div>
      </div>
    </div>
    <div class="form-group row">
      <div class="col-sm-2 col-form-label">
        <label class="control-label-full-width" for="wiki_message">{{
          s__('Wiki|Commit message')
        }}</label>
      </div>
      <div class="col-sm-10">
        <input
          id="wiki_message"
          name="wiki[message]"
          type="text"
          class="form-control qa-wiki-message-textbox"
          :value="commitMessage"
          :placeholder="s__('Wiki|Commit message')"
        />
      </div>
    </div>
    <div class="form-actions">
      <gl-button
        category="primary"
        variant="confirm"
        type="submit"
        class="qa-wiki-submit-button"
        data-testid="wiki-submit-button"
        :disabled="!hasContent || !hasTitle"
        >{{ submitButtonText }}</gl-button
      >
      <gl-button :href="cancelFormPath" class="float-right" data-testid="wiki-cancel-button">{{
        __('Cancel')
      }}</gl-button>
    </div>
  </gl-form>
</template>
