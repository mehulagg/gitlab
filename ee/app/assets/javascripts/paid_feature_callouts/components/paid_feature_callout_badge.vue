<script>
import { GlBadge, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { debounce } from 'lodash';
import { __, sprintf } from '~/locale';
import Tracking from '~/tracking';

const RESIZE_EVENT_DEBOUNCE_MS = 150;
const trackingMixin = Tracking.mixin({ experiment: 'highlight_paid_features_during_active_trial' });

export default {
  components: {
    GlBadge,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [trackingMixin],
  props: {
    featureName: {
      type: String,
      required: false,
      default: '',
    },
  },
  i18n: {
    title: {
      generic: __('This feature is part of your GitLab Ultimate trial.'),
      specific: __('The %{featureName} feature is part of your GitLab Ultimate trial.'),
    },
  },
  trackingEvents: {
    displayBadge: { action: 'display_badge', label: 'feature_highlight_badge' },
  },
  data() {
    return {
      tooltipDisabled: false,
    };
  },
  computed: {
    title() {
      if (this.featureName === '') return this.$options.i18n.title.generic;

      return sprintf(this.$options.i18n.title.specific, { featureName: this.featureName });
    },
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
      const { action, ...options } = this.$options.trackingEvents.displayBadge;
      this.track(action, options);
    },
    updateTooltipDisabledState() {
      this.tooltipDisabled = bp.getBreakpointSize() !== 'xs';
    },
  },
};
</script>

<template>
  <gl-badge
    v-gl-tooltip="{ disabled: tooltipDisabled }"
    :title="title"
    tabindex="0"
    size="sm"
    class="feature-highlight-badge"
  >
    <gl-icon name="license" :size="14" />
  </gl-badge>
</template>
