<script>
import { GlBadge, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { debounce } from 'lodash';
import { __ } from '~/locale';
import Tracking from '~/tracking';

const RESIZE_EVENT_DEBOUNCE_MS = 150;

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
  props: {
    containerId: {
      type: [String, undefined],
      required: false,
      default: undefined,
    },
  },
  data() {
    return {
      tooltipDisabled: false,
    };
  },
  created() {
    this.debouncedResize = debounce(() => this.onResize(), RESIZE_EVENT_DEBOUNCE_MS);
    window.addEventListener('resize', this.debouncedResize);
  },
  mounted() {
    this.trackBadgeDisplayedForExperiment();
    this.onResize();
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.debouncedResize);
  },
  methods: {
    onResize() {
      this.updateTooltipDisabledState();
    },
    trackBadgeDisplayedForExperiment() {
      this.track('display_badge', {
        label: 'feature_highlight_badge',
        property: 'experiment:highlight_paid_features_during_active_trial',
      });
    },
    updateTooltipDisabledState() {
      this.tooltipDisabled = !['xs'].includes(bp.getBreakpointSize());
    },
  },
};
</script>

<template>
  <gl-badge
    :id="containerId"
    v-gl-tooltip="{ disabled: tooltipDisabled }"
    :title="$options.i18n.title"
    tabindex="0"
    size="sm"
    class="feature-highlight-badge"
  >
    <gl-icon name="license" :size="12" />
  </gl-badge>
</template>
