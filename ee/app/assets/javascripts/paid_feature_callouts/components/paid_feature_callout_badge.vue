<script>
import { GlBadge, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
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
    containerId: {
      type: [String, undefined],
      required: false,
      default: undefined,
    },
    featureName: {
      type: [String, undefined],
      required: false,
      default: undefined,
    },
  },
  computed: {
    title() {
      if (this.featureName === undefined) {
        return s__('FeatureHighlight|This feature is part of your GitLab Ultimate trial.');
      }
      const i18nTitle = s__(
        'FeatureHighlight|The %{featureName} feature is part of your GitLab Ultimate trial.',
      );
      return sprintf(i18nTitle, { featureName: this.featureName });
    },
  },
  // TODO:
  // - [ ] only show the tooltip on small screen sizes
  // - [ ] only show the popover on screen sizes larger than "small"
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
    :id="containerId"
    v-gl-tooltip
    :title="title"
    size="sm"
    tabindex
    class="feature-highlight-badge"
  >
    <gl-icon name="license" :size="12" />
  </gl-badge>
</template>
