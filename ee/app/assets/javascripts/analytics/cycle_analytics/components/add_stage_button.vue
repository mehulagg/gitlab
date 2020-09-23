<script>
export default {
  props: {
    active: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    activeClass() {
      return 'active font-weight-bold border-style-solid border-color-blue-300';
    },
    inactiveClass() {
      return 'bg-transparent border-style-dashed border-color-default';
    },
  },
};
</script>
<template>
  <li
    :class="[active ? activeClass : inactiveClass]"
    class="js-add-stage-button stage-nav-item mb-1 rounded d-flex justify-content-center border-width-1px"
    @click.prevent="$emit('showform')"
  >
    {{ s__('CustomCycleAnalytics|Add a stage') }}
  </li>
</template>
