<script>
/* eslint-disable @gitlab/vue-require-i18n-strings */
import $ from 'jquery';
import { GlIcon, GlDropdown, GlSearchBoxByType, GlDropdownItem, } from '@gitlab/ui';
import IssuableTemplateSelectors from '../../../templates/issuable_template_selectors';

export default {
  components: {
    GlIcon,
    GlDropdown,
    GlSearchBoxByType,
    GlDropdownItem,
  },
  props: {
    formState: {
      type: Object,
      required: true,
    },
    issuableTemplates: {
      type: Array,
      required: false,
      default: () => [],
    },
    projectPath: {
      type: String,
      required: true,
    },
    projectNamespace: {
      type: String,
      required: true,
    },
  },
  computed: {
    issuableTemplatesJson() {
      return JSON.stringify(this.issuableTemplates);
    },
  },
  mounted() {
    // Create the editor for the template
    const editor = document.querySelector('.detail-page-description .note-textarea') || {};
    editor.setValue = val => {
      this.formState.description = val;
    };
    editor.getValue = () => this.formState.description;

    this.issuableTemplate = new IssuableTemplateSelectors({
      $dropdowns: $(this.$refs.toggle),
      editor,
    });
  },
};
</script>

<template>
  <div class="dropdown js-issuable-selector-wrap" data-issuable-type="issue">
    <gl-dropdown
      :data-namespace-path="projectNamespace"
      :data-project-path="projectPath"
      :data-data="issuableTemplatesJson"
      data-field-name="issuable_template"
      data-selected="null"
      header-text="Choose a template"
      text="Choose a template"
      class="js-issuable-selector"
      ref="toggle"
    >
      <gl-search-box-by-type class="m-2 " :placeholder="__('Filter')" />
      <gl-dropdown-item
        v-for="template in issuableTemplates"
        :key="template.name"
      >
        {{ template.name }}
      </gl-dropdown-item>
      <div class="dropdown-footer">
        <ul class="dropdown-footer-list">
          <li>
            <a class="no-template">{{ __('No template') }}</a>
          </li>
          <li>
            <a class="reset-template">{{ __('Reset template') }}</a>
          </li>
        </ul>
      </div>
    </gl-dropdown>
  </div>
</template>
