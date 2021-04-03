<script>
import { GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
  },
  props: {
    buttonTitle: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      toggleState: false,
    };
  },
  computed: {
    toggleButtonIcon() {
      return this.toggleState ? 'angle-up' : 'angle-down';
    },
  },
  methods: {
    onClickButton() {
      this.toggleState = !this.toggleState;
      this.$emit('toggleButton', this.toggleState);
    },
  },
};
</script>

<template>
  <button class="btn-link d-flex align-items-center" type="button" @click="onClickButton">
    <gl-icon :size="16" :name="toggleButtonIcon" />
    <span class="gl-ml-3">{{ buttonTitle }}</span>
  </button>
</template>
