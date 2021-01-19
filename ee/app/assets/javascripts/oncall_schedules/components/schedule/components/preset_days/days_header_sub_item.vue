<script>
import { PRESET_TYPES } from 'ee/oncall_schedules/constants';
import updateShiftTimeUnitWidthMutation from 'ee/oncall_schedules/graphql/mutations/update_shift_time_unit_width.mutation.graphql';
import CommonMixin from 'ee/oncall_schedules/mixins/common_mixin';
import { GlResizeObserverDirective } from '@gitlab/ui';

export default {
  PRESET_TYPES,
  directives: {
    GlResizeObserver: GlResizeObserverDirective,
  },
  mixins: [CommonMixin],
  computed: {
    headerSubItems() {
      return Array.from(Array(24).keys());
    },
  },
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
      v-for="(subItem, index) in headerSubItems"
      :key="index"
      ref="dailyHourCell"
      class="sublabel-value"
      data-testid="sublabel-value"
      >{{ subItem }}</span
    >
    <span
      :style="getIndicatorStyles($options.PRESET_TYPES.DAYS)"
      class="current-day-indicator-header preset-days"
    ></span>
  </div>
</template>
