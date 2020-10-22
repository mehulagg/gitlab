<script>
import { GlLink } from '@gitlab/ui';
import { __ } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  components: {
    GlLink,
    TimeAgoTooltip,
  },
  inject: ['autoFixMrsPath'],
  props: {
    pipeline: { type: Object, required: true },
    autoFixMrsCount: {
      type: Number,
      required: false,
      default: 0,
    },
  },
  i18n: {
    title: __(
      'The Security Dashboard shows the results of the last successful pipeline run on the default branch.',
    ),
    lastUpdated: __('Last updated'),
    autoFixSolutions: __('Auto-fix solutions'),
    autoFixMrsLink: __('%{mrsCount} ready for review'),
  },
};
</script>

<template>
  <div>
    <h6 class="gl-font-weight-normal">{{ $options.i18n.title }}</h6>
    <div
      class="gl-border-solid gl-border-1 gl-border-gray-100 gl-p-6 gl-display-flex gl-sm-flex-direction-column"
    >
      <div class="gl-mr-6">
        <span class="gl-font-weight-bold">{{ $options.i18n.lastUpdated }}</span>
        <time-ago-tooltip class="gl-px-3" :time="pipeline.createdAt" />
        <gl-link :href="pipeline.path" target="_blank">#{{ pipeline.id }}</gl-link>
      </div>
      <div v-if="autoFixMrsCount" class="gl-mt-5 gl-sm-mt-0">
        <span class="gl-font-weight-bold">{{ $options.i18n.autoFixSolutions }}</span>
        <gl-link :href="autoFixMrsPath" target="_blank">{{
          sprintf($options.i18n.autoFixMrsLink, { mrsCount: autoFixMrsCount })
        }}</gl-link>
      </div>
    </div>
  </div>
</template>
