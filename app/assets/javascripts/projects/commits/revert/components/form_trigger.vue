<script>
import { GlLink } from '@gitlab/ui';
import eventHub from '../event_hub';
import { OPEN_MODAL } from '../constants';

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
      eventHub.$emit(OPEN_MODAL);
    },
  },
};
</script>

<template>
  <gl-link
    data-is-link="true"
    @click="openModal"
    >{{ displayText }}
  </gl-link>
</template>
