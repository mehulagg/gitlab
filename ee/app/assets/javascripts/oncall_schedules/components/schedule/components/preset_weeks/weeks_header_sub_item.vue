<script>
import updateShiftTimeUnitWidthMutation from 'ee/oncall_schedules/graphql/mutations/update_shift_time_unit_width.mutation.graphql';
import CommonMixin from 'ee/oncall_schedules/mixins/common_mixin';

export default {
  mixins: [CommonMixin],
  props: {
    timeframeItem: {
      type: Date,
      required: true,
    },
  },
  computed: {
    headerSubItems() {
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
    this.$apollo.mutate({
      mutation: updateShiftTimeUnitWidthMutation,
      variables: {
        shiftTimeUnitWidth: this.$refs.weeklyDayCell[0].offsetWidth,
      },
    });
  },
  methods: {
    getSubItemValueClass(subItem) {
      // Show dark color text only for current & upcoming dates
      if (subItem.getTime() === this.$options.currentDate.getTime()) {
        return 'label-dark label-bold';
      } else if (subItem > this.$options.currentDate) {
        return 'label-dark';
      }
      return '';
    },
  },
};
</script>

<template>
  <div class="item-sublabel">
    <span
      v-for="(subItem, index) in headerSubItems"
      :key="index"
      ref="weeklyDayCell"
      :class="getSubItemValueClass(subItem)"
      class="sublabel-value"
      data-testid="sublabel-value"
      >{{ subItem.getDate() }}</span
    >
    <span
      v-if="hasToday"
      :style="getIndicatorStyles()"
      class="current-day-indicator-header preset-weeks"
    ></span>
  </div>
</template>
