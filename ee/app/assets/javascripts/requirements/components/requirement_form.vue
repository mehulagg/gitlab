<script>
import '~/behaviors/markdown/render_gfm';
import $ from 'jquery';
import {
  GlDrawer,
  GlFormGroup,
  GlFormTextarea,
  GlButton,
  GlFormCheckbox,
  GlTooltipDirective,
  GlSafeHtmlDirective as SafeHtml,
} from '@gitlab/ui';
import { isEmpty } from 'lodash';
import { __, sprintf } from '~/locale';
import ZenMode from '~/zen_mode';
import MarkdownField from '~/vue_shared/components/markdown/field.vue';

import RequirementStatusBadge from './requirement_status_badge.vue';

import RequirementMeta from '../mixins/requirement_meta';
import { MAX_TITLE_LENGTH, TestReportStatus } from '../constants';

export default {
  events: {
    drawerClose: 'drawer-close',
    disableEdit: 'disable-edit',
    enableEdit: 'enable-edit',
  },
  titleInvalidMessage: sprintf(__('Requirement title cannot have more than %{limit} characters.'), {
    limit: MAX_TITLE_LENGTH,
  }),
  components: {
    GlDrawer,
    GlFormGroup,
    GlFormTextarea,
    GlFormCheckbox,
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
    enableRequirementEdit: {
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
      satisfied: this.requirement?.satisfied || false,
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
        this.satisfied = value?.satisfied || false;
      },
      deep: true,
    },
    drawerOpen(value) {
      // Clear `title` and `satisfied` value on drawer close.
      if (!value) {
        this.title = '';
        this.description = '';
        this.satisfied = false;
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
    newLastTestReportState() {
      // lastTestReportState determines whether a requirement is satisfied or not.
      // Only create a new test report when manually marking/unmarking a requirement as satisfied:

      // when 1) manually marking a requirement as satisfied for the first time.
      const updateCondition1 = this.requirement.lastTestReportState === null && this.satisfied;
      // or when 2) overriding the status in the latest test report.
      const updateCondition2 =
        this.requirement.lastTestReportState !== null &&
        this.satisfied !== this.requirement.satisfied;

      if (updateCondition1 || updateCondition2) {
        return this.satisfied ? TestReportStatus.Passed : TestReportStatus.Failed;
      }

      return null;
    },
    handleFormInputKeyDown() {
      if (this.zenModeEnabled) {
        // Exit Zen mode, don't close the drawer.
        this.zenModeEnabled = false;
        this.zenMode.exit();
      } else {
        this.$emit(this.$options.events.disableEdit);
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
        eventParams.lastTestReportState = this.newLastTestReportState();
      }

      this.$emit('save', eventParams);
    },
    handleCancel() {
      this.$emit(
        this.isCreate ? this.$options.events.drawerClose : this.$options.events.disableEdit,
      );
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
    @close="$emit($options.events.drawerClose)"
  >
    <template #header>
      <h4 v-if="isCreate" class="gl-m-0">{{ __('New Requirement') }}</h4>
      <div v-else class="gl-display-flex gl-align-items-center">
        <strong class="gl-text-gray-500">{{ reference }}</strong>
        <requirement-status-badge
          v-if="testReport"
          :test-report="testReport"
          :last-test-report-manually-created="requirement.lastTestReportManuallyCreated"
          class="gl-ml-3"
        />
      </div>
    </template>
    <template>
      <div v-if="!enableRequirementEdit && !isCreate" class="requirement-details">
        <div
          class="title-container gl-display-flex gl-border-b-1 gl-border-b-solid gl-border-gray-100"
        >
          <h3 v-safe-html="titleHtml" class="title qa-title gl-flex-grow-1 gl-m-0 gl-mb-3"></h3>
          <gl-button
            v-if="canUpdate && !isArchived"
            v-gl-tooltip.bottom
            data-testid="edit"
            :title="__('Edit title and description')"
            icon="pencil"
            class="btn-edit gl-align-self-start"
            @click="$emit($options.events.enableEdit, $event)"
          />
        </div>
        <div data-testid="descriptionContainer" class="description-container gl-mt-3">
          <div ref="gfmContainer" v-safe-html="descriptionHtml" class="md"></div>
        </div>
      </div>
      <div v-else class="requirement-form">
        <div class="requirement-form-container" :class="{ 'gl-flex-grow-1 gl-mt-2': !isCreate }">
          <div data-testid="form-error-container" class="flash-container"></div>
          <gl-form-group
            data-testid="title"
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
              @keydown.meta.enter="handleSave"
              @keydown.ctrl.enter="handleSave"
            />
          </gl-form-group>
          <gl-form-group data-testid="description" class="common-note-form">
            <label for="requirementDescription" class="d-block col-form-label gl-pb-0!">
              {{ __('Description') }}
            </label>
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
                  @keydown.meta.enter="handleSave"
                  @keydown.ctrl.enter="handleSave"
                ></textarea>
              </template>
            </markdown-field>
            <gl-form-checkbox v-if="!isCreate" v-model="satisfied" class="gl-mt-6">{{
              __('Satisfied')
            }}</gl-form-checkbox>
          </gl-form-group>
          <div class="gl-display-flex requirement-form-actions gl-mt-6">
            <gl-button
              :disabled="disableSaveButton"
              :loading="requirementRequestActive"
              variant="success"
              category="primary"
              class="gl-mr-auto js-requirement-save"
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
