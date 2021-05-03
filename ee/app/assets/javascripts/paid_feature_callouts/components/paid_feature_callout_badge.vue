<script>
import { GlBadge, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { debounce } from 'lodash';
import { sprintf } from '~/locale';
import Tracking from '~/tracking';
import { i18n, RESIZE_EVENT_DEBOUNCE_MS } from '../constants';

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
  computed: {
    title() {
      if (this.featureName === '') return i18n.badge.title.generic;

      return sprintf(i18n.badge.title.specific, { featureName: this.featureName });
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
      this.track('display_badge', {
        label: 'feature_highlight_badge',
        property: 'experiment:highlight_paid_features_during_active_trial',
      });
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
