<script>
import { PRESET_TYPES } from 'ee/oncall_schedules/constants';
import updateShiftTimeUnitWidthMutation from 'ee/oncall_schedules/graphql/mutations/update_shift_time_unit_width.mutation.graphql';
import CommonMixin from 'ee/oncall_schedules/mixins/common_mixin';
import { GlResizeObserverDirective } from '@gitlab/ui';
import { format24HourTimeStringFromInt } from '~/lib/utils/datetime_utility';

export default {
  directives: {
    GlResizeObserver: GlResizeObserverDirective,
  },
  mixins: [CommonMixin],
  props: {
    presetType: {
      type: String,
      required: true,
    },
    timeframeItem: {
      type: Date,
      required: true,
    },
  },
  computed: {
    headerSubItems() {
      if (this.presetType === PRESET_TYPES.DAYS) {
        return Array.from(Array(24).keys((val) => format24HourTimeStringFromInt(val)));
      }

      const timeframeItem = new Date(this.timeframeItem.getTime());
      const headerSubItems = new Array(7)
        .fill()
        .map(
          (val, i) =>
            new Date(
              timeframeItem.getFullYear(),
              timeframeItem.getMonth(),
              timeframeItem.getDate() + i,
            ),
        );

      return headerSubItems;
    },
  },
  mounted() {
    this.updateShiftStyles();
  },
  methods: {
    getSubItemValueClass(subItem) {
      if (this.presetType === PRESET_TYPES.DAYS) {
        return '';
      }

      // Show dark color text only for current & upcoming dates
      if (subItem.getTime() === this.$options.currentDate.getTime()) {
        return 'label-dark label-bold';
      } else if (subItem > this.$options.currentDate) {
        return 'label-dark';
      }
      return '';
    },
    getSubItemValue(subItem) {
      if (this.presetType === PRESET_TYPES.DAYS) {
        return subItem;
      }

      return subItem.getDate();
    },
    updateShiftStyles() {
      this.$apollo.mutate({
        mutation: updateShiftTimeUnitWidthMutation,
        variables: {
          shiftTimeUnitWidth: this.$refs.weeklyDayCell[0].offsetWidth,
        },
      });
    },
  },
};
</script>

<template>
  <div
    v-gl-resize-observer="updateShiftStyles"
    class="item-sublabel"
    data-testid="week-item-sublabel"
  >
    <span
      v-for="(subItem, index) in headerSubItems"
      :key="index"
      ref="weeklyDayCell"
      :class="getSubItemValueClass(subItem)"
      class="sublabel-value"
      data-testid="sublabel-value"
      >{{ getSubItemValue(subItem) }}</span
    >
    <span
      v-if="hasToday"
      :style="getIndicatorStyles()"
      class="current-day-indicator-header preset-weeks"
    ></span>
  </div>
</template>
