<script>
import { GlToggle } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  i18n: {
    toggleLabel: s__('Trial|GitLab Ultimate trial (optional)'),
  },
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
    :label="$options.i18n.toggleLabel"
    label-position="hidden"
    data-testid="trial"
    @change="toggleTrial"
  />
</template>
