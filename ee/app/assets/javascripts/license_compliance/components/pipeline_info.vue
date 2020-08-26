<script>
import { escape } from 'lodash';
import { s__, sprintf } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  name: 'PipelineInfo',
  components: {
    TimeAgoTooltip,
  },
  props: {
    path: {
      required: true,
      type: String,
    },
    timestamp: {
      required: true,
      type: String,
    },
  },
  computed: {
    pipelineText() {
      const { path } = this;
      const body = s__(
        'Licenses|Displays licenses detected in the project, based on the %{linkStart}latest successful%{linkEnd} scan',
      );

      const linkStart = path
        ? `<a href="${escape(path)}" target="_blank" rel="noopener noreferrer">`
        : '';
      const linkEnd = path ? '</a>' : '';

      return sprintf(body, { linkStart, linkEnd }, false);
    },
    hasFullPipelineText() {
      return Boolean(this.path && this.timestamp);
    },
  },

  emits: [],
};
</script>

<template>
  <span v-if="hasFullPipelineText">
    <span v-html="pipelineText"></span>
    <span>•</span>
    <time-ago-tooltip :time="timestamp" />
  </span>

  <span v-else v-html="pipelineText"></span>
</template>
