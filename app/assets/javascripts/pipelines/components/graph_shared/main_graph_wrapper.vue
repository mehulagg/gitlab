<script>
export default {
  props: {
    stageClasses: {
      type: String,
      required: false,
      default: '',
    },
    jobClasses: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>
<template>
  <div>
    <div class="gl-display-flex gl-align-items-center gl-w-full gl-mb-5" :class="stageClasses">
      <slot name="stages"> </slot>
    </div>
    <div
      class="gl-display-flex gl-flex-direction-column gl-align-items-center gl-w-full"
      :class="jobClasses"
    >
      <slot name="jobs"> </slot>
    </div>
  </div>
</template>
