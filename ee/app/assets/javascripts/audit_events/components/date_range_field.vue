<script>
import { GlDaterangePicker } from '@gitlab/ui';
import { dateAtFirstDayOfMonth, getDateInPast } from '~/lib/utils/datetime_utility';
import { CURRENT_DATE, MAX_DATE_RANGE } from '../constants';
import DateRangeButtons from './date_range_buttons.vue';

export default {
  components: {
    DateRangeButtons,
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
      return this.startDate || dateAtFirstDayOfMonth(CURRENT_DATE);
    },
    defaultEndDate() {
      return this.endDate || CURRENT_DATE;
    },
    defaultDateRange() {
      return { startDate: this.defaultStartDate, endDate: this.defaultEndDate };
    },
  },
  methods: {
    onInput({ startDate, endDate }) {
      if (!startDate && endDate) {
        this.$emit('selected', { startDate: getDateInPast(endDate, 1), endDate });
      } else {
        this.$emit('selected', { startDate, endDate });
      }
    },
  },
  CURRENT_DATE,
  MAX_DATE_RANGE,
};
</script>

<template>
  <div
    class="gl-display-flex gl-align-items-flex-end gl-xs-align-items-baseline gl-xs-flex-direction-column"
  >
    <div class="gl-pr-5 gl-mb-5">
      <date-range-buttons :date-range="defaultDateRange" @input="onInput" />
    </div>
    <gl-daterange-picker
      class="gl-display-flex gl-pl-0 gl-w-full"
      :default-start-date="defaultStartDate"
      :default-end-date="defaultEndDate"
      :default-max-date="$options.CURRENT_DATE"
      :max-date-range="$options.MAX_DATE_RANGE"
      :same-day-selection="true"
      start-picker-class="gl-mb-5 gl-pr-5 gl-display-flex gl-flex-direction-column gl-lg-flex-direction-row gl-flex-grow-1 gl-lg-align-items-flex-end"
      end-picker-class="gl-mb-5 gl-lg-pr-5 gl-display-flex gl-flex-direction-column gl-lg-flex-direction-row gl-flex-grow-1 gl-lg-align-items-flex-end"
      @input="onInput"
    />
  </div>
</template>
