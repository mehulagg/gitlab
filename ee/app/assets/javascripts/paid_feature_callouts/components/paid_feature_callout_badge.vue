<script>
import { GlBadge, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import Tracking from '~/tracking';

export default {
  components: {
    GlBadge,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [Tracking.mixin()],
  props: {
    title: {
      type: String,
      required: false,
      default: s__('FeatureHighlight|This feature is part of your GitLab Ultimate trial.'),
    },
  },
  mounted() {
    this.trackBadgeDisplayedForExperiment();
  },
  methods: {
    trackBadgeDisplayedForExperiment() {
      this.track('display_badge', {
        label: 'feature_highlight_badge',
        property: 'experiment:highlight_paid_features_during_active_trial',
      });
    },
  },
};
</script>

<template>
  <gl-badge v-gl-tooltip :title="title" tabindex="0" size="sm" class="feature-highlight-badge">
    <gl-icon name="license" :size="12" />
  </gl-badge>
</template>
