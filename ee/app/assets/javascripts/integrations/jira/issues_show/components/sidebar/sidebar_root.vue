<script>
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';
import Assignees from '~/sidebar/components/assignees/assignees.vue';
import DueDate from './due_date_block.vue';

export default {
  components: {
    LabelsSelect,
    Assignees,
    DueDate,
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
    assignees: {
      type: Array,
      required: true,
    },
    rootPath: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <assignees class="block" :users="assignees" :editable="false" :root-path="rootPath" />
    <due-date class="block" :due-date="new Date()" />
    <labels-select
      :selected-labels="selectedLabels"
      variant="sidebar"
      class="block labels js-labels-block"
      >{{ __('None') }}</labels-select
    >
  </div>
</template>
