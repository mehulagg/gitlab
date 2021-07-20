<script>
import { GlBadge, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { debounce } from 'lodash';
import { sprintf } from '~/locale';
import Tracking from '~/tracking';
import {
  BADGE,
  EXPERIMENT_KEY,
  POPOVER_OR_TOOLTIP_BREAKPOINT,
  RESIZE_EVENT_DEBOUNCE_MS,
} from '../constants';

const { i18n, trackingEvents } = BADGE;
const trackingMixin = Tracking.mixin({ experiment: EXPERIMENT_KEY });

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
  data() {
    return {
      tooltipDisabled: false,
    };
  },
  i18n,
  trackingEvents,
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
      this.tooltipDisabled = bp.getBreakpointSize() !== POPOVER_OR_TOOLTIP_BREAKPOINT;
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
