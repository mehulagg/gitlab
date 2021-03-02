<script>
import { GlEmptyState, GlLink } from '@gitlab/ui';

export default {
  components: {
    GlEmptyState,
    GlLink,
  },
  inject: ['dashboardDocumentation', 'emptyStateSvgPath'],
  props: {
    message: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-empty-state
    :title="s__('SecurityReports|Add projects to your group')"
    :svg-path="emptyStateSvgPath"
  >
    <template #description>
      {{ message }}
      <gl-link :href="dashboardDocumentation">{{ __('More information') }}</gl-link>
    </template>
  </gl-empty-state>
</template>
