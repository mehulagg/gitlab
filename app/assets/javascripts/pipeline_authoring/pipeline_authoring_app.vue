<script>
import { GlEmptyState } from '@gitlab/ui';

export default {
  components: {
    GlEmptyState,
  },
};
</script>

<template>
  <gl-empty-state
    :title="s__('Pipelines|Pipeline Authoring')"
    description="We are beginning our work around building the foundation for a dedicated pipeline authoring area and the pipeline visual builder."
    :primary-button-text="__('Learn more')"
    primary-button-link="https://about.gitlab.com/direction/verify/pipeline_authoring/"
  />
</template>
