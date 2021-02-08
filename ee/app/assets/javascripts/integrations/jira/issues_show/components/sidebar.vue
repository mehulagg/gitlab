<script>
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';

export default {
  components: {
    LabelsSelect,
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
  },
};
</script>

<template>
  <labels-select
    :selected-labels="selectedLabels"
    variant="sidebar"
    class="block labels js-labels-block"
    >{{ __('None') }}</labels-select
  >
</template>
