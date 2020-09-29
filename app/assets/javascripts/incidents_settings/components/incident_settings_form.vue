<script>
import { GlFormCheckbox } from '@gitlab/ui';

export default {
  components: {
    GlFormCheckbox,
  },
  data() {
    return {
      enabled: false,
    };
  },
};
</script>

<template>
  <div>
    <gl-form-checkbox v-model="enabled">
      <span>{{ __('hello') }}</span>
    </gl-form-checkbox>
  </div>
</template>
