<script>
import { GlLink } from '@gitlab/ui';
import { __ } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  components: {
    GlLink,
    TimeAgoTooltip,
  },
  props: {
    pipeline: { type: Object, required: true },
  },
  i18n: {
    title: __(
      'The Security Dashboard shows the results of the last successful pipeline run on the default branch.',
    ),
    label: __('Last updated'),
  },
};
</script>

<template>
  <div>
    <h6 class="gl-font-weight-normal">{{ $options.i18n.title }}</h6>
    <div class="gl-border-solid gl-border-1 gl-border-gray-100 gl-p-6">
      <span class="gl-font-weight-bold">{{ $options.i18n.label }}</span>
      <time-ago-tooltip class="gl-px-3" :time="pipeline.createdAt" />
      <gl-link :href="pipeline.path" target="_blank">#{{ pipeline.id }}</gl-link>
    </div>
  </div>
</template>
