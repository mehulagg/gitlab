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

  emits: [],
};
</script>
<template>
  <div class="bar d-flex">
    <div v-for="(step, index) in steps" :key="index" :class="classObject(index)">
      {{ index + 1 }}. {{ step }}
    </div>
  </div>
</template>
