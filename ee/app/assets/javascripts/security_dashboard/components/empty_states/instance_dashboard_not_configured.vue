<script>
import { GlButton, GlEmptyState, GlLink } from '@gitlab/ui';

export default {
  components: {
    GlEmptyState,
    GlButton,
    GlLink,
  },
  inject: ['dashboardDocumentation', 'emptyStateSvgPath', 'instanceDashboardSettingsPath'],
};
</script>

<template>
  <gl-empty-state
    :title="s__('SecurityReports|Add a project to your dashboard')"
    :svg-path="emptyStateSvgPath"
  >
    <template #description>
      {{
        s__(
          'SecurityReports|The security dashboard displays the latest security findings for projects you wish to monitor. Select "Edit dashboard" to add and remove projects.',
        )
      }}
      <gl-link :href="dashboardDocumentation">{{
        s__('SecurityReports|More information')
      }}</gl-link>
    </template>
    <template #actions>
      <gl-button variant="success" :href="instanceDashboardSettingsPath">
        {{ s__('SecurityReports|Add projects') }}
      </gl-button>
    </template>
  </gl-empty-state>
</template>
