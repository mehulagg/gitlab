<script>
export default {
  name: 'StageCardListItem',
  props: {
    isActive: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      activeClass: 'active font-weight-bold border-color-blue-300',
      inactiveClass: 'bg-transparent border-color-default',
    };
  },
};
</script>

<template>
  <div
    :class="[isActive ? activeClass : inactiveClass]"
    class="stage-nav-item d-flex px-4 m-0 mb-1 rounded border-width-1px border-style-solid"
  >
    <slot></slot>
  </div>
</template>
