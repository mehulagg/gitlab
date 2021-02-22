<script>
import { labelsFilterParam } from 'ee/integrations/jira/issues_show/constants';

import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';
import Assignee from './assignee.vue';

export default {
  name: 'JiraIssuesSidebar',
  components: {
    Assignee,
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
      return (this.issue?.assignees || [])[0];
    },
  },
  labelsFilterParam,
};
</script>

<template>
  <div>
    <assignee class="block" :assignee="assignee" />

    <labels-select
      :selected-labels="issue.labels"
      :labels-filter-base-path="issuesListPath"
      :labels-filter-param="$options.labelsFilterParam"
      variant="sidebar"
      class="block labels js-labels-block"
    >
      {{ __('None') }}
    </labels-select>
  </div>
</template>
