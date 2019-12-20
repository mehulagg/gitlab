<script>
const SCALE_STEP_SIZE = 0.1;
const DEFAULT_SCALE = 1;

export default {
  data() {
    return {
      scale: DEFAULT_SCALE,
    };
  },
  methods: {
    setScale(scale) {
      if (scale <= 0) {
        return;
      }

      this.scale = scale;
      this.$emit('change', this.scale);
    },
    incrementScale() {
      this.setScale(this.scale + SCALE_STEP_SIZE);
    },
    decrementScale() {
      this.setScale(this.scale - SCALE_STEP_SIZE);
    },
    resetScale() {
      this.setScale(DEFAULT_SCALE);
    },
  },
  DEFAULT_SCALE,
};
</script>

<template>
  <div class="design-scaler d-flex-center w-100 p-3">
    <button class="btn" @click="decrementScale">-</button>
    <button class="btn" :disabled="zoomScale === $options.DEFAULT_SCALE" @click="resetScale">
      Reset
    </button>
    <button class="btn" @click="incrementScale">+</button>
  </div>
</template>
