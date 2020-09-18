<script>
import { GlDaterangePicker, GlButtonGroup, GlButton } from '@gitlab/ui';
import { sprintf, __, s__ } from '~/locale';
import { getDayDifference, getStartOfMonth, getDateInPast } from '~/lib/utils/datetime_utility';

const CURRENT_DATE = new Date();

export default {
  components: {
    GlButton,
    GlButtonGroup,
    GlDaterangePicker,
  },
  props: {
    startDate: {
      type: Date,
      required: false,
      default: null,
    },
    endDate: {
      type: Date,
      required: false,
      default: null,
    },
  },
  computed: {
    defaultStartDate() {
      return this.startDate || getStartOfMonth(CURRENT_DATE);
    },
    defaultEndDate() {
      return this.endDate || CURRENT_DATE;
    },
  },
  methods: {
    spanSelected({ date }) {
      this.onInput({
        startDate: date,
        endDate: CURRENT_DATE,
      });
    },
    onInput(dates) {
      this.$emit('selected', dates);
    },
    isStartingDate(selectedDate) {
      return getDayDifference(selectedDate, this.defaultStartDate) === 0;
    },
  },
  CURRENT_DATE,
  maxDateRange: 31,
  timeSpans: [
    { label: sprintf(__('Last %{days} days'), { days: 7 }), date: getDateInPast(CURRENT_DATE, 7) },
    {
      label: sprintf(__('Last %{days} days'), { days: 14 }),
      date: getDateInPast(CURRENT_DATE, 14),
    },
    { label: s__('ContributionAnalytics|Last month'), date: getStartOfMonth(CURRENT_DATE) },
  ],
};
</script>

<template>
  <div class="gl-display-flex gl-sm-align-items-flex-end gl-xs-flex-direction-column">
    <div class="gl-pr-5 gl-mb-5">
      <gl-button-group>
        <gl-button
          v-for="(span, idx) in $options.timeSpans"
          :selected="isStartingDate(span.date)"
          @click="spanSelected(span)"
          :key="idx"
          >{{ span.label }}</gl-button
        >
      </gl-button-group>
    </div>
    <gl-daterange-picker
      class="gl-display-flex gl-pl-0 gl-w-full"
      :default-start-date="defaultStartDate"
      :default-end-date="defaultEndDate"
      :default-max-date="$options.CURRENT_DATE"
      :max-date-range="$options.maxDateRange"
      start-picker-class="gl-mb-5 gl-pr-5 gl-lg-align-items-center gl-display-flex gl-flex-direction-column gl-lg-flex-direction-row gl-flex-fill-1"
      end-picker-class="gl-mb-5 gl-lg-align-items-center gl-display-flex gl-flex-direction-column gl-lg-flex-direction-row gl-flex-fill-1"
      @input="onInput"
    />
  </div>
</template>
