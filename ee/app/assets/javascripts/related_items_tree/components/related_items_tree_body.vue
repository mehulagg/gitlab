<script>
export default {
  props: {
    parentItem: {
      type: Object,
      required: true,
    },
    children: {
      type: Array,
      required: false,
      default: () => [],
    },
  },

  emits: [],
};
</script>

<template>
  <div class="related-items-tree-body sortable-container">
    <tree-root :parent-item="parentItem" :children="children" />
  </div>
</template>
