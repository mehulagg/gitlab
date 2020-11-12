<script>
export default {
  props: {
    // dom target to watch for changes
    targetParent: {
      type: Element,
      required: true,
    },
    // preselected labels
    selectedLabels: {
      type: Array,
      required: false,
      default: () => [],
    },
    // list of labels for this project
    labels: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      appliedLabels: this.selectedLabels,
    };
  },
  methods: {},
  mounted() {
    console.log('Mounted::js-applied-labels');
    console.log('Mounted::target', this.targetParent);
  },
};
</script>
<template>
  <div class="issuable-show-labels">
    <template v-for="label in appliedLabels">
      <gl-label
        :key="label.id"
        :target="labelFilterUrl(label)"
        :background-color="label.color"
        :title="label.title"
        :description="label.description"
        :scoped="showScopedLabels(label)"
      />
    </template>
  </div>
</template>
