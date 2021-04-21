<script>
import { GlBadge, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';
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
  i18n: {
    title: __('This feature is part of your GitLab Ultimate trial.'),
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
  <gl-badge
    v-gl-tooltip
    :title="$options.i18n.title"
    tabindex="0"
    size="sm"
    class="feature-highlight-badge"
  >
    <gl-icon name="license" :size="12" />
  </gl-badge>
</template>
