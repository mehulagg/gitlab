<script>
import $ from 'jquery';
import {
  GlDrawer,
  GlFormGroup,
  GlFormTextarea,
  GlButton,
  GlTooltipDirective,
  GlSafeHtmlDirective as SafeHtml,
} from '@gitlab/ui';
import { isEmpty } from 'lodash';
import { __, sprintf } from '~/locale';
import ZenMode from '~/zen_mode';

import MarkdownField from '~/vue_shared/components/markdown/field.vue';

import RequirementStatusBadge from './requirement_status_badge.vue';

import RequirementMeta from '../mixins/requirement_meta';
import { MAX_TITLE_LENGTH } from '../constants';

export default {
  titleInvalidMessage: sprintf(__('Requirement title cannot have more than %{limit} characters.'), {
    limit: MAX_TITLE_LENGTH,
  }),
  components: {
    GlDrawer,
    GlFormGroup,
    GlFormTextarea,
    GlButton,
    MarkdownField,
    RequirementStatusBadge,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    SafeHtml,
  },
  mixins: [RequirementMeta],
  inject: ['descriptionPreviewPath', 'descriptionHelpPath'],
  props: {
    drawerOpen: {
      type: Boolean,
      required: true,
    },
    requirement: {
      type: Object,
      required: false,
      default: null,
    },
    editMode: {
      type: Boolean,
      required: false,
      default: false,
    },
    requirementRequestActive: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      zenModeEnabled: false,
      title: this.requirement?.title || '',
      description: this.requirement?.description || '',
    };
  },
  computed: {
    isCreate() {
      return isEmpty(this.requirement);
    },
    fieldLabel() {
      return this.isCreate ? __('New Requirement') : __('Edit Requirement');
    },
    saveButtonLabel() {
      return this.isCreate ? __('Create requirement') : __('Save changes');
    },
    titleInvalid() {
      return this.title?.length > MAX_TITLE_LENGTH;
    },
    disableSaveButton() {
      return this.title === '' || this.titleInvalid || this.requirementRequestActive;
    },
  },
  watch: {
    requirement: {
      handler(value) {
        this.title = value?.title || '';
        this.description = value?.description || '';
      },
      deep: true,
    },
    drawerOpen(value) {
      // Clear `title` value on drawer close.
      if (!value) {
        this.title = '';
        this.description = '';
        this.enableEditing = false;
      }
    },
  },
  mounted() {
    this.zenMode = new ZenMode();
    $(this.$refs.gfmContainer).renderGFM();
    $(document).on('zen_mode:enter', () => {
      this.zenModeEnabled = true;
    });
    $(document).on('zen_mode:leave', () => {
      this.zenModeEnabled = false;
    });
  },
  beforeDestroy() {
    $(document).off('zen_mode:enter');
    $(document).off('zen_mode:leave');
  },
  methods: {
    getDrawerHeaderHeight() {
      const wrapperEl = document.querySelector('.js-requirements-container-wrapper');

      if (wrapperEl) {
        return `${wrapperEl.offsetTop}px`;
      }

      return '';
    },
    handleEditClick() {
      this.enableEditing = true;
    },
    handleCancelClick() {
      this.enableEditing = false;
    },
    handleFormInputKeyDown() {
      if (this.zenModeEnabled) {
        // Exit Zen mode, don't close the drawer.
        this.zenModeEnabled = false;
        this.zenMode.exit();
      } else {
        this.$emit('disable-edit');
      }
    },
    handleSave() {
      const { title, description } = this;
      const eventParams = {
        title,
        description,
      };

      if (!this.isCreate) {
        eventParams.iid = this.requirement.iid;
      }

      this.$emit('save', eventParams);
    },
    handleCancel() {
      this.$emit(this.isCreate ? 'drawer-close' : 'disable-edit');
    },
  },
};
</script>

<template>
  <gl-drawer
    :open="drawerOpen"
    :header-height="getDrawerHeaderHeight()"
    :class="{ 'zen-mode gl-absolute': zenModeEnabled }"
    class="requirement-form-drawer"
    @close="$emit('drawer-close')"
  >
    <template #header>
      <h4 v-if="isCreate" class="m-0">{{ __('New Requirement') }}</h4>
      <div v-else class="gl-display-flex gl-align-items-center">
        <strong class="text-muted">{{ reference }}</strong>
        <requirement-status-badge v-if="testReport" :test-report="testReport" class="gl-ml-3" />
      </div>
    </template>
    <template>
      <div v-if="!editMode && !isCreate" class="requirement-details">
        <div
          class="title-container gl-display-flex gl-border-b-1 gl-border-b-solid gl-border-gray-100"
        >
          <h3
            v-safe-html="titleHtml"
            class="title qa-title gl-flex-grow-1 gl-m-0 gl-mb-3"
            dir="auto"
          ></h3>
          <gl-button
            v-if="canUpdate"
            v-gl-tooltip.bottom
            :title="__('Edit title and description')"
            icon="pencil"
            class="btn-edit gl-align-self-start"
            @click="$emit('enable-edit', $event)"
          />
        </div>
        <div class="description-container gl-mt-3">
          <div ref="gfmContainer" v-safe-html="descriptionHtml" class="md"></div>
        </div>
      </div>
      <div v-else class="requirement-form">
        <div class="requirement-form-container" :class="{ 'flex-grow-1 mt-1': !isCreate }">
          <gl-form-group
            :label="__('Title')"
            :invalid-feedback="$options.titleInvalidMessage"
            :state="!titleInvalid"
            class="gl-show-field-errors"
            label-for="requirementTitle"
          >
            <gl-form-textarea
              id="requirementTitle"
              v-model.trim="title"
              autofocus
              resize
              :disabled="requirementRequestActive"
              :placeholder="__('Requirement title')"
              max-rows="25"
              class="requirement-form-textarea"
              :class="{ 'gl-field-error-outline': titleInvalid }"
              @keydown.escape.exact.stop="handleFormInputKeyDown"
            />
          </gl-form-group>
          <gl-form-group
            :label="__('Description')"
            label-for="requirementDescription"
            label-class="gl-pb-0!"
            class="common-note-form"
          >
            <markdown-field
              :markdown-preview-path="descriptionPreviewPath"
              :markdown-docs-path="descriptionHelpPath"
              :enable-autocomplete="false"
              :textarea-value="description"
            >
              <template #textarea>
                <textarea
                  id="requirementDescription"
                  v-model="description"
                  :data-supports-quick-actions="false"
                  :aria-label="__('Description')"
                  :placeholder="__('Describe the requirement here')"
                  class="note-textarea js-gfm-input js-autosize markdown-area qa-description-textarea"
                  @keydown.escape.exact.stop="handleFormInputKeyDown"
                ></textarea>
              </template>
            </markdown-field>
          </gl-form-group>
          <div class="d-flex requirement-form-actions">
            <gl-button
              :disabled="disableSaveButton"
              :loading="requirementRequestActive"
              variant="success"
              category="primary"
              class="mr-auto js-requirement-save"
              @click="handleSave"
            >
              {{ saveButtonLabel }}
            </gl-button>
            <gl-button
              variant="default"
              category="primary"
              class="js-requirement-cancel"
              @click="handleCancel"
            >
              {{ __('Cancel') }}
            </gl-button>
          </div>
        </div>
      </div>
    </template>
  </gl-drawer>
</template>
