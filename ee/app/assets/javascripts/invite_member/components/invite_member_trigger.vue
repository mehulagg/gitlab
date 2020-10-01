<script>
import { GlLink } from '@gitlab/ui';
import eventHub from '../event_hub';

export default {
  components: {
    GlLink,
  },
  inject: {
    displayText: {
      default: '',
    },
  },
  methods: {
    openModal() {
      eventHub.$emit('openModal');
    },
  },
};
</script>

<template>
  <gl-link data-is-link="true" @click="openModal">{{ displayText }}</gl-link>
</template>
