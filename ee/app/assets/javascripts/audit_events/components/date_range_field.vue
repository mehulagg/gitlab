<script>
import { GlDaterangePicker } from '@gitlab/ui';

export default {
  components: {
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
  methods: {
    onInput(dates) {
      this.$emit('selected', dates);
    },
  },
};
</script>

<template>
  <gl-daterange-picker
    class="d-flex flex-wrap flex-sm-nowrap"
    :default-start-date="startDate"
    :default-end-date="endDate"
    start-picker-class="form-group align-items-lg-center mr-0 mr-sm-1 d-flex flex-column flex-lg-row"
    end-picker-class="form-group align-items-lg-center mr-0 mr-sm-2 d-flex flex-column flex-lg-row"
    @input="onInput"
  />
</template>
