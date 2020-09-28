<script>
import { GlDrawer, GlFormGroup, GlFormTextarea, GlFormCheckbox, GlButton } from '@gitlab/ui';
import { isEmpty } from 'lodash';
import { __, sprintf } from '~/locale';

import { MAX_TITLE_LENGTH, TestReportStatus } from '../constants';

export default {
  titleInvalidMessage: sprintf(__('Requirement title cannot have more than %{limit} characters.'), {
    limit: MAX_TITLE_LENGTH,
  }),
  components: {
    GlDrawer,
    GlFormGroup,
    GlFormTextarea,
    GlFormCheckbox,
    GlButton,
  },
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
    requirementRequestActive: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      title: this.requirement?.title || '',
      satisfied: this.requirement?.satisfied || false,
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
      return this.title.length > MAX_TITLE_LENGTH;
    },
    disableSaveButton() {
      return this.title === '' || this.titleInvalid || this.requirementRequestActive;
    },
    reference() {
      return `REQ-${this.requirement?.iid}`;
    },
  },
  watch: {
    requirement: {
      handler(value) {
        this.title = value?.title || '';
        this.satisfied = value?.satisfied || false;
      },
      deep: true,
    },
    drawerOpen(value) {
      // Clear `title` value on drawer close.
      if (!value) {
        this.title = '';
        this.satisfied = false;
      }
    },
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
      // So marking/unmarking a requirement actually creates a new test report.

      // We should avoid creating a new test report when
      // 1) lastTestReportState was null (never set) and requirement is unsatisfied.
      const updateCondition1 = this.requirement.lastTestReportState === null && this.satisfied;
      // 2) and the satisfied status didn't change.
      const updateCondition2 =
        this.requirement.lastTestReportState !== null &&
        this.satisfied !== this.requirement.satisfied;

      if (updateCondition1 || updateCondition2) {
        return this.satisfied ? TestReportStatus.Passed : TestReportStatus.Failed;
      }

      return null;
    },
    handleSave() {
      if (this.isCreate) {
        this.$emit('save', this.title);
      } else {
        this.$emit('save', {
          iid: this.requirement.iid,
          title: this.title,
          lastTestReportState: this.newLastTestReportState(),
        });
      }
    },
  },
};
</script>

<template>
  <gl-drawer :open="drawerOpen" :header-height="getDrawerHeaderHeight()" @close="$emit('cancel')">
    <template #header>
      <h4 class="gl-m-0">{{ fieldLabel }}</h4>
    </template>
    <template>
      <div class="requirement-form">
        <span v-if="!isCreate" class="text-muted">{{ reference }}</span>
        <div class="requirement-form-container" :class="{ 'gl-flex-grow-1 gl-mt-2': !isCreate }">
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
              :placeholder="__('Describe the requirement here')"
              max-rows="25"
              class="requirement-form-textarea"
              :class="{ 'gl-field-error-outline': titleInvalid }"
              @keyup.escape.exact="$emit('cancel')"
            />
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
              @click="$emit('cancel')"
            >
              {{ __('Cancel') }}
            </gl-button>
          </div>
        </div>
      </div>
    </template>
  </gl-drawer>
</template>
