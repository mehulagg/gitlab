<script>
import { GlBadge, GlIcon } from '@gitlab/ui';

export default {
  components: { GlBadge, GlIcon },
  inject: {
    pipelineSecurityBuildsFailedCount: { type: Number, required: false, default: 0 },
    pipelineSecurityBuildsFailedPath: { type: String, required: false, default: '' },
  },
};
</script>

<template>
  <gl-badge
    v-if="pipelineSecurityBuildsFailedCount > 0"
    variant="danger"
    :href="pipelineSecurityBuildsFailedPath"
  >
    <gl-icon name="status_failed" class="gl-mr-2" />
    {{
      n__('%d failed security job', '%d failed security jobs', pipelineSecurityBuildsFailedCount)
    }}
  </gl-badge>
</template>
