<script>
import { GlEmptyState, GlLink } from '@gitlab/ui';
import { GEO_FEATURE_URL } from '../constants';

export default {
  name: 'GeoNodesEmptyState',
  components: {
    GlEmptyState,
    GlLink,
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
  <gl-empty-state :title="__('Discover GitLab Geo')" :svg-path="svgPath">
    <template #description>
      <span>{{
        __(
          'Make everyone on your team more productive regardless of their location. GitLab Geo creates read-only mirrors of your GitLab instance so you can reduce the time it takes to clone and fetch large repos.',
        )
      }}</span>
      <gl-link class="gl-ml-2" :href="$options.GEO_FEATURE_URL" target="_blank">{{
        __('Learn more')
      }}</gl-link>
    </template>
  </gl-empty-state>
</template>
