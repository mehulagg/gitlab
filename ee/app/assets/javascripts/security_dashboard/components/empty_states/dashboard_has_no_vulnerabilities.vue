<script>
import { GlEmptyState } from '@gitlab/ui';

export default {
  components: {
    GlEmptyState,
  },
  inject: ['emptyStateSvgPath', 'dashboardDocumentation'],
};
</script>

<template>
  <gl-empty-state
    :title="s__(`SecurityReports|No vulnerabilities found`)"
    :svg-path="emptyStateSvgPath"
    :primary-button-link="dashboardDocumentation"
    :primary-button-text="s__('SecurityReports|Learn more about setting up your dashboard')"
    :description="
      s__(
        `SecurityReports|While it's rare to have no vulnerabilities, it can happen. In any event, we ask that you double check your settings to make sure you've set up your dashboard correctly.`,
      )
    "
  />
</template>
