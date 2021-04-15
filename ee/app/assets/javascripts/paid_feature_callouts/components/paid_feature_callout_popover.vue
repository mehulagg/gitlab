<script>
import { GlPopover, GlSprintf } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { debounce } from 'lodash';
import { __, n__, sprintf } from '~/locale';
import Tracking from '~/tracking';

const RESIZE_EVENT_DEBOUNCE_MS = 150;

export default {
  components: {
    GlPopover,
    GlSprintf,
  },
  mixins: [Tracking.mixin()],
  props: {
    containerId: {
      type: [String, null],
      required: false,
      default: null,
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
    promoImagePath: {
      type: [String, undefined],
      required: false,
      default: undefined,
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
  i18n: {
    popoverContent: __(`Enjoying your GitLab %{planNameForTrial} trial? To continue using
      %{featureName} after your trial ends, upgrade to GitLab %{planNameForUpgrade}.`),
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
      this.disabled = ['xs'].includes(bp.getBreakpointSize());
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

    <gl-sprintf :message="$options.i18n.popoverContent">
      <template #featureName>{{ featureName }}</template>
      <template #planNameForTrial>{{ planNameForTrial }}</template>
      <template #planNameForUpgrade>{{ planNameForUpgrade }}</template>
    </gl-sprintf>
  </gl-popover>
</template>
