<script>
import { GlForm, GlFormGroup, GlFormInput, GlIcon, GlFormSelect, GlLink } from '@gitlab/ui';

export default {
  components: {
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlFormSelect,
    GlIcon,
    GlLink,
  },
  props: {
    action: {
      type: String,
      required: true,
    },
    formatOptions: {
      type: Object,
      required: true,
    },
    method: {
      type: String,
      required: false,
      default: 'POST',
    },
    classes: {
      type: String,
      required: false,
      default: '',
    },
    pageInfo: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    helpPath() {
      if (this.pageInfo.persisted) return `${this.pageInfo.helpPath}#moving-a-wiki-page`;
      return `${this.pageInfo.helpPath}#creating-a-new-wiki-page`;
    },
  },
};
</script>

<template>
  <gl-form :action="action" :method="method" :class="classes">
    <input
      :v-if="pageInfo.persisted"
      type="hidden"
      name="last_commit_sha"
      :v-model="pageInfo.lastCommitSha"
    />
    <div class="form-group row">
      <div class="col-sm-2 col-form-label">
        <label class="control-label-full-width" for="wiki_title">{{ s__('Wiki|Title') }}</label>
      </div>
      <div class="col-sm-10">
        <input
          id="wiki_title"
          type="text"
          class="form-control qa-wiki-title-textbox"
          :v-model="pageInfo.title"
          :required="true"
          :autofocus="!pageInfo.persisted"
          :placeholder="s__('Wiki|Page title')"
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
          <gl-link :href="helpPath" target="_blank"><gl-icon name="question-o" /></gl-link>
        </span>
      </div>
    </div>
    <div class="form-group row">
      <div class="col-sm-2 col-form-label">
        <label class="control-label-full-width" for="wiki_format">{{ s__('Wiki|Format') }}</label>
      </div>
      <div class="col-sm-10">
        <select class="form-control" :v-model="pageInfo.format">
          <option v-for="(key, label) of formatOptions" :key="key" :name="key">
            {{ label }}
          </option>
        </select>
      </div>
    </div>
    <div class="form-group row">
      <div class="col-sm-2 col-form-label">
        <label class="control-label-full-width" for="wiki_commit_message">{{
          s__('Wiki|Commit message')
        }}</label>
      </div>
      <div class="col-sm-10">
        <input
          id="wiki_commit_message"
          type="text"
          class="form-control qa-wiki-message-textbox"
          :v-model="pageInfo.title"
          :required="true"
          :autofocus="!pageInfo.persisted"
          :placeholder="s__('Wiki|Commit message')"
        />
      </div>
    </div>
  </gl-form>
</template>
