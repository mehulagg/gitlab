<script>
import { GlSprintf } from '@gitlab/ui';
import { SEVERITY_CLASS_NAME_MAP } from './constants';

export default {
  components: {
    GlSprintf,
  },
  props: {
    message: {
      type: Object,
      required: true,
    },
  },
  methods: {
    getSeverityClass(severity) {
      return SEVERITY_CLASS_NAME_MAP[severity];
    },
  },
};
</script>

<template>
  <span>
    <gl-sprintf :message="message.message">
      <template v-for="slotName in ['critical', 'high', 'other']" #[slotName]="{content}">
        <span :key="slotName">
          <strong v-if="Boolean(message[slotName])" :class="getSeverityClass(slotName)">
            {{ content }}
          </strong>
          <span v-else>{{ content }}</span>
        </span>
      </template>
    </gl-sprintf>
  </span>
</template>
