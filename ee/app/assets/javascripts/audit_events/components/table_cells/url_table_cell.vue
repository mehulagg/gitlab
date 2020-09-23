<script>
import { s__ } from '~/locale';

const REMOVED_TEXT = s__('AuditLogs|(removed)');

export default {
  props: {
    url: {
      type: String,
      required: false,
      default: '',
    },
    name: {
      type: String,
      required: true,
    },
  },
  REMOVED_TEXT,
};
</script>

<template>
  <a v-if="url" :href="url">{{ name }}</a>

  <span v-else>
    {{ name }} <small>{{ $options.REMOVED_TEXT }}</small>
  </span>
</template>
