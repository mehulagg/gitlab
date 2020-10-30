<script>
import { GlDatepicker, GlFormInput } from '@gitlab/ui';

const PLACEHOLDER = 'YYYY-MM-DD';

export default {
  name: 'ExpiresAtField',
  components: { GlDatepicker, GlFormInput },
  props: {
    objectName: {
      type: String,
      required: true,
    },
    fieldName: {
      type: String,
      required: true,
    },
  },
  computed: {
    inputId() {
      return `${this.objectName}_${this.fieldName}`;
    },
    inputName() {
      return `${this.objectName}[${this.fieldName}]`;
    },
  },
  PLACEHOLDER,
};
</script>

<template>
  <gl-datepicker :target="null" :min-date="new Date()">
    <gl-form-input
      :id="inputId"
      :name="inputName"
      class="datepicker form-control gl-datepicker-input"
      :placeholder="$options.PLACEHOLDER"
      autocomplete="off"
      inputmode="nonde"
      data-qa-seletor="expiry_date_field"
    />
  </gl-datepicker>
</template>
