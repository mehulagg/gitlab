<script>
import { GlEmptyState, GlLink } from '@gitlab/ui';

export default {
  components: {
    GlEmptyState,
    GlLink,
  },
  inject: ['dashboardDocumentation', 'emptyStateSvgPath', 'instanceDashboardSettingsPath'],
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
    :title="s__('SecurityReports|Add a project to your dashboard')"
    :svg-path="emptyStateSvgPath"
    :primary-button-text="s__('SecurityReports|Settings')"
    :primary-button-link="instanceDashboardSettingsPath"
  >
    <template #description>
      {{ message }}
      <gl-link :href="dashboardDocumentation">{{ __('More information') }}</gl-link>
    </template>
  </gl-empty-state>
</template>
