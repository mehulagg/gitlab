<script>
import { GlEmptyState } from '@gitlab/ui';

export default {
  name: 'UnavailableState',
  components: { GlEmptyState },
  props: {
    svgPath: {
      type: String,
      required: true,
    },
    link: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-empty-state
    :svg-path="svgPath"
    :title="s__('SecurityReports|Oops, something doesn\'t seem right.')"
    :description="
      s__(
        'SecurityReports|Either you don\'t have permission to view this dashboard or the dashboard has not been setup. Please check your permission settings with your administrator or check your dashboard configurations to proceed.',
      )
    "
    :primary-button-link="link"
    :primary-button-text="s__('SecurityReports|Learn more about setting up your dashboard')"
  />
</template>
