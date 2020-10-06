<script>
import { GlLink } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  components: {
    GlLink,
    TimeAgoTooltip,
  },
  props: { projectFullPath: { type: String, required: true } },
  inject: ['pipelineCreatedAt', 'pipelineId', 'pipelinePath'],
  i18n: {
    title: __(
      'The Security Dashboard shows the results of the last successful pipeline run on the default branch.',
    ),
    label: __('Last updated'),
  },
  computed: {
    showStatus() {
      return Boolean(this.pipelineCreatedAt && this.pipelineId && this.pipelinePath);
    },
    pipelineText() {
      return sprintf('#%{pipelineId}', { pipelineId: this.pipelineId });
    },
  },
};
</script>

<template>
  <div v-if="showStatus">
    <h6 class="gl-font-weight-normal">{{ $options.i18n.title }}</h6>
    <div class="gl-border-solid gl-border-1 gl-border-gray-100 gl-p-6">
      <span class="gl-font-weight-bold">{{ $options.i18n.label }}</span>
      <time-ago-tooltip class="gl-px-3" :time="pipelineCreatedAt" />
      <gl-link :href="pipelinePath" target="_blank">{{ pipelineText }}</gl-link>
    </div>
  </div>
</template>
