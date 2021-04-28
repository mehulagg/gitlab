<script>
import { GlPopover } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { debounce } from 'lodash';
import { n__, s__, sprintf } from '~/locale';
import Tracking from '~/tracking';

const RESIZE_EVENT_DEBOUNCE_MS = 150;

export default {
  components: {
    GlPopover,
  },
  mixins: [Tracking.mixin()],
  props: {
    containerId: {
      type: String,
      required: false,
      default: undefined,
    },
    daysRemaining: {
      type: Number,
      required: true,
    },
    featureName: {
      type: String,
      required: true,
    },
    planNameForTrial: {
      type: String,
      required: true,
    },
    planNameForUpgrade: {
      type: String,
      required: true,
    },
    targetId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      disabled: false,
    };
  },
  computed: {
    popoverTitle() {
      const i18nPopoverTitle = n__(
        'FeatureHighlight|%{daysRemaining} day remaining to enjoy %{featureName}',
        'FeatureHighlight|%{daysRemaining} days remaining to enjoy %{featureName}',
        this.daysRemaining,
      );

      return sprintf(i18nPopoverTitle, {
        daysRemaining: this.daysRemaining,
        featureName: this.featureName,
      });
    },
    popoverContent() {
      const i18nPopoverContent = s__(`FeatureHighlight|Enjoying your GitLab %{planNameForTrial} trial? To continue
        using %{featureName} after your trial ends, upgrade to GitLab %{planNameForUpgrade}.`);

      return sprintf(i18nPopoverContent, {
        featureName: this.featureName,
        planNameForTrial: this.planNameForTrial,
        planNameForUpgrade: this.planNameForUpgrade,
      });
    },
  },
  created() {
    this.debouncedResize = debounce(() => this.onResize(), RESIZE_EVENT_DEBOUNCE_MS);
    window.addEventListener('resize', this.debouncedResize);
  },
  mounted() {
    this.onResize();
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.debouncedResize);
  },
  methods: {
    onResize() {
      this.updateDisabledState();
    },
    onShown() {
      this.track('popover_shown', {
        label: `feature_highlight_popover:${this.featureName}`,
        property: 'experiment:highlight_paid_features_during_active_trial',
      });
    },
    updateDisabledState() {
      this.disabled = bp.getBreakpointSize() === 'xs';
    },
  },
};
</script>

<template>
  <gl-popover
    :container="containerId"
    :target="targetId"
    :disabled="disabled"
    placement="top"
    boundary="viewport"
    :delay="{ hide: 400 }"
    @shown="onShown"
  >
    <template #title>{{ popoverTitle }}</template>

    {{ popoverContent }}
  </gl-popover>
</template>
