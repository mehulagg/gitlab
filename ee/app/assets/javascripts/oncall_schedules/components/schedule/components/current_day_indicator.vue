<script>
import CommonMixin from '../mixins/common_mixin';

export default {
  mixins: [CommonMixin],
  props: {
    presetType: {
      type: String,
      required: true,
    },
    timeframeItem: {
      type: [Date, Object],
      required: true,
    },
  },
  data() {
    return {
      indicatorStyles: {},
    };
  },
  mounted() {
    this.indicatorStyles = this.getIndicatorStyles();
  },
};
</script>

<template>
  <span v-if="hasToday" :style="indicatorStyles" class="current-day-indicator"></span>
</template>
