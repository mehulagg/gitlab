<script>
import WeeksHeaderItem from './preset_weeks/weeks_header_item.vue';

export default {
  components: {
    WeeksHeaderItem,
  },

  props: {
    presetType: {
      type: String,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
  },
};
</script>

<template>
  <div class="timeline-section clearfix">
    <span class="timeline-header-blank"></span>
    <weeks-header-item
      v-for="(timeframeItem, index) in timeframe"
      :key="index"
      :timeframe-index="index"
      :timeframe-item="timeframeItem"
      :timeframe="timeframe"
    />
  </div>
</template>
