<script>
import { GlTooltipDirective as GlTooltip, GlButton, GlIcon, GlLoadingIcon } from '@gitlab/ui';
import Mousetrap from 'mousetrap';

import { s__, __ } from '~/locale';
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';

import TestCaseGraphQL from '../mixins/test_case_graphql';

export default {
  components: {
    GlButton,
    GlIcon,
    GlLoadingIcon,
    LabelsSelect,
  },
  directives: {
    GlTooltip,
  },
  inject: [
    'projectFullPath',
    'testCaseId',
    'canEditTestCase',
    'labelsFetchPath',
    'labelsManagePath',
  ],
  mixins: [TestCaseGraphQL],
  props: {
    sidebarExpanded: {
      type: Boolean,
      required: true,
    },
    todo: {
      type: Object,
      required: false,
      default: null,
    },
    selectedLabels: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      sidebarExpandedOnClick: false,
      testCaseLabelsSelectInProgress: false,
    };
  },
  computed: {
    isTodoPending() {
      return this.todo?.state === 'pending';
    },
    todoUpdateInProgress() {
      return this.$apollo.queries.testCase.loading || this.testCaseTodoUpdateInProgress;
    },
    todoActionText() {
      return this.isTodoPending ? __('Mark as done') : __('Add a to do');
    },
    todoIcon() {
      return this.isTodoPending ? 'todo-done' : 'todo-add';
    },
  },
  mounted() {
    Mousetrap.bind('l', this.handleLabelsCollapsedButtonClick);
  },
  methods: {
    handleTodoButtonClick() {
      if (this.isTodoPending) {
        this.markTestCaseTodoDone();
      } else {
        this.addTestCaseAsTodo();
      }
    },
    toggleSidebar() {
      document.querySelector('.js-toggle-right-sidebar-button').dispatchEvent(new Event('click'));
    },
    handleLabelsDropdownClose() {
      if (this.sidebarExpandedOnClick) {
        this.sidebarExpandedOnClick = false;
        this.toggleSidebar();
      }
    },
    handleLabelsCollapsedButtonClick() {
      // Expand the sidebar if not already expanded.
      if (!this.sidebarExpanded) {
        this.toggleSidebar();
        this.sidebarExpandedOnClick = true;
      }

      // Wait for sidebar expand to complete before
      // revealing labels dropdown.
      this.$nextTick(() => {
        document
          .querySelector('.js-labels-block .js-sidebar-dropdown-toggle')
          .dispatchEvent(new Event('click', { bubbles: true, cancelable: false }));
      });
    },
    handleUpdateSelectedLabels(labels) {
      // Iterate over selection and check if labels which were
      // either selected or removed aren't leading to same selection
      // as current one, as then we don't want to make network call
      // since nothing has changed.
      const anyLabelUpdated = labels.some(label => {
        // Find this label in existing selection.
        const existingLabel = this.selectedLabels.find(l => l.id === label.id);

        // Check either of the two following conditions;
        // 1. A label that's not currently applied is being applied.
        // 2. A label that's already applied is being removed.
        return (!existingLabel && label.set) || (existingLabel && !label.set);
      });

      // Only proceed with action if there are any label updates to be done.
      if (anyLabelUpdated) {
        this.testCaseLabelsSelectInProgress = true;

        return this.updateTestCase({
          variables: {
            addLabelIds: labels.filter(label => label.set).map(label => label.id),
            removeLabelIds: labels.filter(label => !label.set).map(label => label.id),
          },
          errorMessage: s__('TestCases|Something went wrong while updating the test case labels.'),
        })
          .then(updatedTestCase => {
            this.$emit('test-case-updated', updatedTestCase);
          })
          .finally(() => {
            this.testCaseLabelsSelectInProgress = false;
          });
      }
      return null;
    },
  },
};
</script>

<template>
  <div class="test-case-sidebar-items">
    <template v-if="canEditTestCase">
      <div v-if="sidebarExpanded" data-testid="todo" class="block todo gl-display-flex">
        <span class="gl-flex-grow-1">{{ __('To Do') }}</span>
        <gl-button :loading="todoUpdateInProgress" size="small" @click="handleTodoButtonClick">{{
          todoActionText
        }}</gl-button>
      </div>
      <div v-else class="block todo">
        <button
          v-gl-tooltip.viewport="{ placement: 'left' }"
          :title="todoActionText"
          class="btn-blank sidebar-collapsed-icon"
          @click="handleTodoButtonClick"
        >
          <gl-loading-icon v-if="todoUpdateInProgress" />
          <gl-icon v-else :name="todoIcon" :class="{ 'todo-undone': isTodoPending }" />
        </button>
      </div>
    </template>
    <labels-select
      :allow-label-edit="canEditTestCase"
      :allow-label-create="true"
      :allow-multiselect="true"
      :allow-scoped-labels="true"
      :selected-labels="selectedLabels"
      :labels-select-in-progress="testCaseLabelsSelectInProgress"
      :labels-fetch-path="labelsFetchPath"
      :labels-manage-path="labelsManagePath"
      variant="sidebar"
      class="block labels js-labels-block"
      @updateSelectedLabels="handleUpdateSelectedLabels"
      @onDropdownClose="handleLabelsDropdownClose"
      @toggleCollapse="handleLabelsCollapsedButtonClick"
      >{{ __('None') }}</labels-select
    >
  </div>
</template>
