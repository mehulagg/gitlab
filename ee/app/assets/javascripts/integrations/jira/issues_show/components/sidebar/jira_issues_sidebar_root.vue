<script>
import { labelsFilterParam } from 'ee/integrations/jira/issues_show/constants';
import { __, s__ } from '~/locale';
import CopyableField from '~/vue_shared/components/sidebar/copyable_field.vue';
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import Assignee from './assignee.vue';
import IssueDueDate from './issue_due_date.vue';
import IssueField from './issue_field.vue';

export default {
  name: 'JiraIssuesSidebar',
  components: {
    Assignee,
    IssueDueDate,
    IssueField,
    CopyableField,
    LabelsSelect,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: {
    issuesListPath: {
      default: null,
    },
  },
  props: {
    sidebarExpanded: {
      type: Boolean,
      required: true,
    },
    issue: {
      type: Object,
      required: true,
    },
    isLoadingStatus: {
      type: Boolean,
      required: false,
      default: false,
    },
    isUpdatingStatus: {
      type: Boolean,
      required: false,
      default: false,
    },
    statuses: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    assignee() {
      // Jira issues have at most 1 assignee
      return (this.issue.assignees || [])[0];
    },
    reference() {
      return this.issue.references?.relative;
    },
    canUpdateStatus() {
      return this.glFeatures.jiraIssueDetailsEditStatus;
    },
  },
  labelsFilterParam,
  i18n: {
    statusTitle: __('Status'),
    statusDropdownEmpty: s__('JiraService|No available statuses'),
    statusDropdownTitle: __('Change status'),
    referenceName: __('Reference'),
  },
  mounted() {
    this.sidebarEl = document.querySelector('aside.right-sidebar');
    this.sidebarToggleEl = document.querySelector('.js-toggle-right-sidebar-button');
  },
  methods: {
    toggleSidebar() {
      this.sidebarToggleEl.dispatchEvent(new Event('click'));
    },
    expandSidebarAndOpenDropdown(dropdownRef = null) {
      // Expand the sidebar if not already expanded.
      if (!this.sidebarExpanded) {
        this.toggleSidebar();
      }

      if (dropdownRef) {
        // Wait for sidebar expand animation to complete
        // before revealing the dropdown.
        this.sidebarEl.addEventListener(
          'transitionend',
          () => {
            dropdownRef.expand();
          },
          { once: true },
        );
      }
    },
    onIssueStatusFetch() {
      this.$emit('issue-status-fetch');
    },
    onIssueStatusUpdated(status) {
      this.$emit('issue-status-updated', status);
    },
  },
};
</script>

<template>
  <div>
    <assignee class="block" :assignee="assignee" />
    <issue-due-date :due-date="issue.dueDate" />
    <issue-field
      icon="progress"
      :can-update="canUpdateStatus"
      :dropdown-title="$options.i18n.statusDropdownTitle"
      :dropdown-empty="$options.i18n.statusDropdownEmpty"
      :items="statuses"
      :loading="isLoadingStatus"
      :title="$options.i18n.statusTitle"
      :updating="isUpdatingStatus"
      :value="issue.status"
      @expand-sidebar="expandSidebarAndOpenDropdown"
      @issue-field-fetch="onIssueStatusFetch"
      @issue-field-updated="onIssueStatusUpdated"
    />
    <labels-select
      :selected-labels="issue.labels"
      :labels-filter-base-path="issuesListPath"
      :labels-filter-param="$options.labelsFilterParam"
      variant="sidebar"
      class="block labels js-labels-block"
    >
      {{ __('None') }}
    </labels-select>
    <copyable-field
      v-if="reference"
      class="block"
      :name="$options.i18n.referenceName"
      :value="reference"
    />
  </div>
</template>
