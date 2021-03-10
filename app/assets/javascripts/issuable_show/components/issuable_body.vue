<script>
import { GlLink } from '@gitlab/ui';

import createFlash from '~/flash';
import { s__, sprintf } from '~/locale';
import TaskList from '~/task_list';
import '~/behaviors/markdown/render_gfm';

import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

import { IssuableTypeText } from '../constants';

import IssuableDescription from './issuable_description.vue';
import IssuableEditForm from './issuable_edit_form.vue';
import IssuableTitle from './issuable_title.vue';

export default {
  components: {
    GlLink,
    TimeAgoTooltip,
    IssuableTitle,
    IssuableDescription,
    IssuableEditForm,
  },
  props: {
    issuable: {
      type: Object,
      required: true,
    },
    statusBadgeClass: {
      type: String,
      required: true,
    },
    statusIcon: {
      type: String,
      required: true,
    },
    enableEdit: {
      type: Boolean,
      required: true,
    },
    enableAutocomplete: {
      type: Boolean,
      required: true,
    },
    enableAutosave: {
      type: Boolean,
      required: true,
    },
    editFormVisible: {
      type: Boolean,
      required: true,
    },
    showFieldTitle: {
      type: Boolean,
      required: true,
    },
    descriptionPreviewPath: {
      type: String,
      required: true,
    },
    descriptionHelpPath: {
      type: String,
      required: true,
    },
    taskListUpdatePath: {
      type: String,
      required: true,
    },
  },
  computed: {
    isUpdated() {
      return Boolean(this.issuable.updatedAt);
    },
    updatedBy() {
      return this.issuable.updatedBy;
    },
  },
  mounted() {
    if (this.enableEdit && this.taskListUpdatePath) {
      this.initTaskList();
    }
  },
  methods: {
    initTaskList() {
      this.taskList = new TaskList({
        dataType: 'issue', // Only `issue` types can have task lists.
        fieldName: 'description',
        lockVersion: this.issuable.lockVersion || 1,
        selector: '.detail-page-description',
        onError: this.handleTaskListUpdateFailure.bind(this),
      });
    },
    handleTaskListUpdateFailure() {
      createFlash(
        sprintf(
          s__(
            'Someone edited this %{issueType} at the same time you did. The description has been updated and you will need to make your changes again.',
          ),
          {
            issueType: IssuableTypeText[this.issuable.type],
          },
        ),
      );

      this.$emit('task-list-update-fail');
    },
    handleKeydownTitle(e, issuableMeta) {
      this.$emit('keydown-title', e, issuableMeta);
    },
    handleKeydownDescription(e, issuableMeta) {
      this.$emit('keydown-description', e, issuableMeta);
    },
  },
};
</script>

<template>
  <div class="issue-details issuable-details">
    <div class="detail-page-description content-block">
      <issuable-edit-form
        v-if="editFormVisible"
        :issuable="issuable"
        :enable-autocomplete="enableAutocomplete"
        :enable-autosave="enableAutosave"
        :show-field-title="showFieldTitle"
        :description-preview-path="descriptionPreviewPath"
        :description-help-path="descriptionHelpPath"
        @keydown-title="handleKeydownTitle"
        @keydown-description="handleKeydownDescription"
      >
        <template #edit-form-actions="issuableMeta">
          <slot name="edit-form-actions" v-bind="issuableMeta"></slot>
        </template>
      </issuable-edit-form>
      <template v-else>
        <issuable-title
          :issuable="issuable"
          :status-badge-class="statusBadgeClass"
          :status-icon="statusIcon"
          :enable-edit="enableEdit"
          @edit-issuable="$emit('edit-issuable', $event)"
        >
          <template #status-badge>
            <slot name="status-badge"></slot>
          </template>
        </issuable-title>
        <issuable-description
          v-if="issuable.descriptionHtml"
          :issuable="issuable"
          :can-edit="enableEdit"
          :task-list-update-path="taskListUpdatePath"
        />
        <small v-if="isUpdated" class="edited-text gl-font-sm!">
          {{ __('Edited') }}
          <time-ago-tooltip :time="issuable.updatedAt" tooltip-placement="bottom" />
          <span v-if="updatedBy">
            {{ __('by') }}
            <gl-link :href="updatedBy.webUrl" class="author-link gl-font-sm!">
              <span>{{ updatedBy.name }}</span>
            </gl-link>
          </span>
        </small>
      </template>
    </div>
  </div>
</template>
