<script>
import { GlResizeObserverDirective } from '@gitlab/ui';
import { PRESET_TYPES, HOURS_IN_DAY } from 'ee/oncall_schedules/constants';
import updateShiftTimeUnitWidthMutation from 'ee/oncall_schedules/graphql/mutations/update_shift_time_unit_width.mutation.graphql';
import CommonMixin from 'ee/oncall_schedules/mixins/common_mixin';

export default {
  PRESET_TYPES,
  HOURS_IN_DAY,
  directives: {
    GlResizeObserver: GlResizeObserverDirective,
  },
  mixins: [CommonMixin],
  mounted() {
    this.updateShiftStyles();
  },
  methods: {
    updateShiftStyles() {
      this.$apollo.mutate({
        mutation: updateShiftTimeUnitWidthMutation,
        variables: {
          shiftTimeUnitWidth: this.$refs.dailyHourCell[0].offsetWidth,
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
    data-testid="day-item-sublabel"
  >
    <span
      v-for="hour in $options.HOURS_IN_DAY"
      :key="hour"
      ref="dailyHourCell"
      class="sublabel-value"
      data-testid="sublabel-value"
      >{{ hour }}</span
    >
    <span
      :style="getIndicatorStyles($options.PRESET_TYPES.DAYS)"
      class="current-day-indicator-header preset-days"
      data-testid="day-item-sublabel-current-indicator"
    ></span>
  </div>
</template>
