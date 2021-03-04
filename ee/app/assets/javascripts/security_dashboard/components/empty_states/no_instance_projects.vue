<script>
import { GlEmptyState, GlLink } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlEmptyState,
    GlLink,
  },
  inject: ['dashboardDocumentation', 'emptyStateSvgPath', 'instanceDashboardSettingsPath'],
  i18n: {
    description: s__(
      'SecurityReports|The latest security findings for projects you wish to monitor are displayed here. Select "Settings" to add and remove projects.',
    ),
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
      {{ $options.i18n.description }}
      <gl-link :href="dashboardDocumentation">{{ __('More information') }}</gl-link>
    </template>
  </gl-empty-state>
</template>
