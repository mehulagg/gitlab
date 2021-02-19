<script>
import IssueDueDate from 'ee/integrations/jira/issues_show/components/issue_due_date.vue';
import IssueReference from 'ee/integrations/jira/issues_show/components/issue_reference.vue';
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';

export default {
  components: {
    IssueDueDate,
    IssueReference,
    LabelsSelect,
  },
  props: {
    dueDate: {
      type: String,
      required: false,
      default: null,
    },
    reference: {
      type: String,
      required: false,
      default: null,
    },
    sidebarExpanded: {
      type: Boolean,
      required: true,
    },
    selectedLabels: {
      type: Array,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <issue-due-date :due-date="dueDate" />
    <labels-select
      :selected-labels="selectedLabels"
      variant="sidebar"
      class="block labels js-labels-block"
      >{{ __('None') }}</labels-select
    >
    <issue-reference v-if="reference" :reference="reference" />
  </div>
</template>
