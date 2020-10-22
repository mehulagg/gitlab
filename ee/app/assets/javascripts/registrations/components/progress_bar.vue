<script>
export default {
  props: {
    steps: {
      type: Array,
      required: true,
    },
    currentStep: {
      type: String,
      required: true,
    },
  },
  computed: {
    currentStepIndex() {
      return this.steps.indexOf(this.currentStep);
    },
  },
  methods: {
    classObject(stepIndex) {
      return {
        phase: true,
        bold: true,
        center: true,
        finished: this.currentStepIndex > stepIndex,
        current: this.currentStepIndex === stepIndex,
      };
    },
  },
};
</script>
<template>
  <ol class="bar gl-display-flex gl-p-0 gl-m-0">
    <li v-for="(step, index) in steps" :key="index" :class="classObject(index)">
      {{ step }}
    </li>
  </ol>
</template>
