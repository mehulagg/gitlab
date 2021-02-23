<script>
import { GlEmptyState } from '@gitlab/ui';
import { GEO_FEATURE_URL } from '../constants';

export default {
  name: 'GeoNodesEmptyState',
  components: {
    GlEmptyState,
  },
  props: {
    svgPath: {
      type: String,
      required: true,
    },
  },
  GEO_FEATURE_URL,
};
</script>

<template>
  <gl-empty-state
    :title="s__('Geo|Discover GitLab Geo')"
    :svg-path="svgPath"
    :description="
      s__(
        'Geo|Make everyone on your team more productive regardless of their location. GitLab Geo creates read-only mirrors of your GitLab instance so you can reduce the time it takes to clone and fetch large repos.',
      )
    "
    :primary-button-link="$options.GEO_FEATURE_URL"
    :primary-button-text="s__('Geo|Learn more about Geo')"
  />
</template>
