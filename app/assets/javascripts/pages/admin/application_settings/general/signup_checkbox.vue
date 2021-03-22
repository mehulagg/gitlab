<script>
import { GlFormCheckbox } from '@gitlab/ui';

export default {
  components: {
    GlFormCheckbox,
  },
  props: {
    name: {
      type: String,
      required: true,
    },
    helpText: {
      type: String,
      required: false,
      default: '',
    },
    label: {
      type: String,
      required: true,
    },
    value: {
      type: Boolean,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <input :name="name" type="hidden" :value="value ? '1' : '0'" />

    <gl-form-checkbox :checked="value" @input="$emit('input', $event)">
      {{ label }}
      <template v-if="helpText" #help>{{ helpText }}</template>
    </gl-form-checkbox>
  </div>
</template>
