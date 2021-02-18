<script>
import IssueReference from 'ee/integrations/jira/issues_show/components/issue_reference.vue';
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';

export default {
  components: {
    LabelsSelect,
    IssueReference,
  },
  props: {
    sidebarExpanded: {
      type: Boolean,
      required: true,
    },
    selectedLabels: {
      type: Array,
      required: true,
    },
    reference: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <labels-select
      :selected-labels="selectedLabels"
      variant="sidebar"
      class="block labels js-labels-block"
      >{{ __('None') }}</labels-select
    >
    <issue-reference :reference="reference" />
  </div>
</template>
