<script>
import { GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlIcon,
  },
  props: {
    target: {
      type: String,
      required: true,
    },
  },
  i18n: {
    notSet: s__('CorpusManagement|Not Set'),
  },
  computed: {
    hasTarget() {
      return Boolean(this.target);
    },
  },
};
</script>
<template>
  <span v-if="hasTarget" class="gl-text-gray-900"> {{ target }} </span>
  <span v-else class="gl-text-gray-900">
    <gl-icon class="gl-mr-1" :size="16" name="information-o" />
    {{ this.$options.i18n.notSet }}
  </span>
</template>
