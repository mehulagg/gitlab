<script>
import { labelsFilterParam } from 'ee/integrations/jira/issues_show/constants';
import { __ } from '~/locale';
import CopyableField from '~/vue_shared/components/sidebar/copyable_field.vue';
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';
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
  },
  computed: {
    assignee() {
      // Jira issues have at most 1 assignee
      return (this.issue.assignees || [])[0];
    },
    reference() {
      return this.issue.references?.relative;
    },
  },
  labelsFilterParam,
  i18n: {
    statusTitle: __('Status'),
    referenceName: __('Reference'),
  },
};
</script>

<template>
  <div>
    <assignee class="block" :assignee="assignee" />
    <issue-due-date :due-date="issue.dueDate" />
    <issue-field icon="progress" :title="$options.i18n.statusTitle" :value="issue.status" />
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
