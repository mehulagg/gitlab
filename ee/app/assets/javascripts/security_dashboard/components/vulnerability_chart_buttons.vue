<script>
import { GlButton } from '@gitlab/ui';
import { n__ } from '~/locale';

export default {
  name: 'VulnerabilityChartButtons',
  components: {
    GlButton,
  },
  props: {
    days: {
      type: Array,
      required: true,
    },
    activeDay: {
      type: Number,
      required: true,
    },
  },
  computed: {
    buttonContent() {
      return (days) => n__('1 Day', '%d Days', days);
    },
  },
  methods: {
    clickHandler(days) {
      this.$emit('click', days);
    },
  },
};
</script>

<template>
  <div class="btn-group w-100">
    <gl-button
      v-for="day in days"
      :key="day"
      :class="{ selected: activeDay === day }"
      :data-days="day"
      @click="clickHandler(day)"
    >
      {{ buttonContent(day) }}
    </gl-button>
  </div>
</template>
