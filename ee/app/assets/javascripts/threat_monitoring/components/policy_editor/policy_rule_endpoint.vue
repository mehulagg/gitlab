<script>
import { GlFormInput } from '@gitlab/ui';

export default {
  components: {
    GlFormInput,
  },
  props: {
    value: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <!-- placeholder is the same in all languages-->
  <!-- eslint-disable @gitlab/vue-require-i18n-attribute-strings -->
  <gl-form-input
    class="gl-bg-white!"
    placeholder="key:value"
    :value="value"
    @input="$emit('input', $event)"
  />
  <!-- eslint-enable @gitlab/vue-require-i18n-attribute-strings -->
</template>
