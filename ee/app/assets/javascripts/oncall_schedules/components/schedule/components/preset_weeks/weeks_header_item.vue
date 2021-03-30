<script>
import { TIMELINE_CELL_WIDTH } from 'ee/oncall_schedules/constants';
import CommonMixin from 'ee/oncall_schedules/mixins/common_mixin';
import { monthInWords } from '~/lib/utils/datetime_utility';
import WeeksHeaderSubItem from './weeks_header_sub_item.vue';

export default {
  components: {
    WeeksHeaderSubItem,
  },
  mixins: [CommonMixin],
  props: {
    timeframeIndex: {
      type: Number,
      required: true,
    },
    timeframeItem: {
      type: Date,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
  },
  computed: {
    lastDayOfCurrentWeek() {
      const lastDayOfCurrentWeek = new Date(this.timeframeItem.getTime());
      lastDayOfCurrentWeek.setDate(lastDayOfCurrentWeek.getDate() + 7);

      return lastDayOfCurrentWeek;
    },
    timelineHeaderLabel() {
      const timeframeItemMonth = this.timeframeItem.getMonth();
      const timeframeItemDate = this.timeframeItem.getDate();

      if (this.timeframeIndex === 0 || (timeframeItemMonth === 0 && timeframeItemDate <= 7)) {
        return `${monthInWords(this.timeframeItem, true)} ${timeframeItemDate}`;
      }

      return `${monthInWords(this.timeframeItem, true)} ${timeframeItemDate}`;
    },
    timelineHeaderClass() {
      const currentDateTime = this.$options.currentDate.getTime();
      const lastDayOfCurrentWeekTime = this.lastDayOfCurrentWeek.getTime();

      if (
        currentDateTime >= this.timeframeItem.getTime() &&
        currentDateTime <= lastDayOfCurrentWeekTime
      ) {
        return 'label-bold';
      }

      return '';
    },
    timelineHeaderStyles() {
      return {
        width: `calc((${100}% - ${TIMELINE_CELL_WIDTH}px) / ${2})`,
      };
    },
  },
};
</script>

<template>
  <span class="timeline-header-item" :style="timelineHeaderStyles">
    <div
      :class="timelineHeaderClass"
      class="item-label label-dark gl-pl-5 gl-py-4"
      data-testid="timeline-header-label"
    >
      {{ timelineHeaderLabel }}
    </div>
    <weeks-header-sub-item :timeframe-item="timeframeItem" />
  </span>
</template>
