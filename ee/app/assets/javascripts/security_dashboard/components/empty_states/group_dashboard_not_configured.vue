<script>
import { GlEmptyState } from '@gitlab/ui';

export default {
  components: {
    GlEmptyState,
  },
  inject: ['dashboardDocumentation', 'emptyStateSvgPath'],
};
</script>

<template>
  <gl-empty-state
    :title="s__('SecurityReports|Add projects to your group')"
    :description="
      s__(
        'SecurityReports|The security dashboard displays the latest security findings for projects you wish to monitor. Add projects to your group to view their vulnerabilities here.',
      )
    "
    :primary-button-link="dashboardDocumentation"
    :primary-button-text="s__('SecurityReports|Learn more about setting up your dashboard')"
    :svg-path="emptyStateSvgPath"
  />
</template>
