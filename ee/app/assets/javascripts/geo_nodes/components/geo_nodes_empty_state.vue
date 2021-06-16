<script>
import { GlEmptyState } from '@gitlab/ui';
import { s__ } from '~/locale';
import { GEO_FEATURE_URL } from '../constants';

export default {
  name: 'GeoNodesEmptyState',
  i18n: {
    emptyStateTitle: s__('Geo|Discover GitLab Geo'),
    emptyStateDescription: s__(
      'Geo|Make everyone on your team more productive regardless of their location. GitLab Geo creates read-only mirrors of your GitLab instance so you can reduce the time it takes to clone and fetch large repos.',
    ),
    emptyStateButton: s__('Geo|Learn more about Geo'),
  },
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
    :title="$options.i18n.emptyStateTitle"
    :svg-path="svgPath"
    :description="$options.i18n.emptyStateDescription"
    :primary-button-link="$options.GEO_FEATURE_URL"
    :primary-button-text="$options.i18n.emptyStateButton"
  />
</template>
