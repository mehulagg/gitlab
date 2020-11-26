<script>
import { EPIC_DETAILS_CELL_WIDTH, TIMELINE_CELL_MIN_WIDTH } from '../constants';

import CommonMixin from '../mixins/common_mixin';

import MonthsHeaderItem from './preset_months/months_header_item.vue';
import QuartersHeaderItem from './preset_quarters/quarters_header_item.vue';
import WeeksHeaderItem from './preset_weeks/weeks_header_item.vue';

export default {
  components: {
    QuartersHeaderItem,
    MonthsHeaderItem,
    WeeksHeaderItem,
  },
  mixins: [CommonMixin],
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
  data() {
    return {
      scrolledHeaderClass: '',
    };
  },
  computed: {
    headerItemComponentForPreset() {
      if (this.presetTypeQuarters) {
        return 'quarters-header-item';
      } else if (this.presetTypeMonths) {
        return 'months-header-item';
      } else if (this.presetTypeWeeks) {
        return 'weeks-header-item';
      }
      return '';
    },
/*    sectionContainerStyles() {

      return this.$refs.timelineSection
      return {
        width: `${EPIC_DETAILS_CELL_WIDTH + TIMELINE_CELL_MIN_WIDTH * this.timeframe.length}px`,
      };
    },*/
  },
};
</script>

<template>
  <div class="roadmap-timeline-section clearfix"
  >
    <span class="timeline-header-blank"></span>
    <component
      :is="headerItemComponentForPreset"
      v-for="(timeframeItem, index) in timeframe"
      :key="index"
      :timeframe-index="index"
      :timeframe-item="timeframeItem"
      :timeframe="timeframe"
    />
  </div>
</template>
