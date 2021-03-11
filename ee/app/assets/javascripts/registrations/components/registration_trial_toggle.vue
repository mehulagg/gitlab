<script>
import { GlToggle } from '@gitlab/ui';

export default {
  components: {
    GlToggle,
  },
  props: {
    active: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      trial: this.active,
    };
  },
  mounted() {
    this.toggleTrial();
  },
  methods: {
    toggleTrial() {
      this.$emit('changed', {
        trial: this.trial,
      });
    },
  },
};
</script>
<template>
  <gl-toggle
    v-model="trial"
    name="trial"
    :label="s__('Trial|GitLab Ultimate trial (optional)')"
    label-position="hidden"
    data-testid="trial"
    @change="toggleTrial"
  />
</template>
