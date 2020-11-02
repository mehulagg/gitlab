<script>
import { GlBadge, GlIcon } from '@gitlab/ui';

export default {
  components: { GlBadge, GlIcon },
  inject: {
    pipelineSecurityBuildsFailedCount: { default: 0 },
    pipelineSecurityBuildsFailedPath: { default: '' },
  },
};
</script>

<template>
  <gl-badge variant="danger" :href="pipelineSecurityBuildsFailedPath">
    <gl-icon name="status_failed" class="gl-mr-2" />
    {{
      n__('%d failed security job', '%d failed security jobs', pipelineSecurityBuildsFailedCount)
    }}
  </gl-badge>
</template>
