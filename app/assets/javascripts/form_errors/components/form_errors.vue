<script>
import { GlAlert } from '@gitlab/ui';
import { isString } from 'lodash';

export default {
  components: {
    GlAlert,
  },
  props: {
    errors: {
      type: Array,
      validator: (errors) =>
        errors.every((error) => isString(error)),
      required: true,
    },
  },
};
</script>
<template>
  <gl-alert variant="danger" :dismissible="false">
    <ul>
      <li v-for="error in errors" :key="error">{{ error }}</li>
    </ul>
  </gl-alert>
</template>
