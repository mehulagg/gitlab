<script>
const SCALE_STEP_SIZE = 0.2;
const DEFAULT_SCALE = 1;
const MIN_SCALE = 1;
const MAX_SCALE = 2;

export default {
  data() {
    return {
      scale: DEFAULT_SCALE,
    };
  },
  computed: {
    disableReset() {
      return this.scale <= MIN_SCALE;
    },
    disableDecrease() {
      return this.scale === DEFAULT_SCALE;
    },
    disableIncrease() {
      return this.scale >= MAX_SCALE;
    },
  },
  methods: {
    setScale(scale) {
      if (scale < MIN_SCALE) {
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
};
</script>

<template>
  <div class="design-scaler">
    <button class="btn" :disabled="disableDecrease" @click="decrementScale">-</button>
    <button class="btn" :disabled="disableReset" @click="resetScale">
      Reset
    </button>
    <button class="btn" :disabled="disableIncrease" @click="incrementScale">+</button>
  </div>
</template>
