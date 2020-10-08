<script>
import { GlDatepicker, GlFormInput } from '@gitlab/ui';
import { getDateInFuture } from '~/lib/utils/datetime_utility';

export default {
  name: 'ExpirationDatepicker',
  components: { GlDatepicker, GlFormInput },
  props: {
    initialDate: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      selectedDate: this.initialDate ? new Date(this.initialDate) : null,
    };
  },
  computed: {
    minDate() {
      // Members expire at the beginning of the day.
      // The first selectable day should be tomorrow.
      const today = new Date();
      const beginningOfToday = new Date(today.setHours(0, 0, 0, 0));
      return getDateInFuture(beginningOfToday, 1);
    },
  },
};
</script>

<template>
  <!-- `:target="null"` allows the datepicker to be opened on focus -->
  <!-- `:container="null"` renders the datepicker in the body to prevent conflicting CSS table styles -->
  <gl-datepicker v-model="selectedDate" :target="null" :container="null" :min-date="minDate">
    <template #default="{ formattedDate }">
      <gl-form-input
        class="gl-datepicker-input gl-w-full"
        :value="formattedDate"
        :placeholder="__('Expiration date')"
        autocomplete="off"
      />
    </template>
  </gl-datepicker>
</template>
