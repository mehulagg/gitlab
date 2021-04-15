<script>
import { GlBadge, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { debounce } from 'lodash';
import { __, sprintf } from '~/locale';
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
  data() {
    return {
      tooltipDisabled: false,
    };
  },
  computed: {
    title() {
      if (this.featureName === undefined) {
        return __('This feature is part of your GitLab Ultimate trial.');
      }
      const i18nTitle = __('The %{featureName} feature is part of your GitLab Ultimate trial.');
      return sprintf(i18nTitle, { featureName: this.featureName });
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
      this.tooltipDisabled = !['xs'].includes(bp.getBreakpointSize());
    },
  },
};
</script>

<template>
  <gl-badge
    :id="containerId"
    v-gl-tooltip="{ disabled: tooltipDisabled }"
    :title="title"
    tabindex="0"
    size="sm"
    class="feature-highlight-badge"
  >
    <gl-icon name="license" :size="12" />
  </gl-badge>
</template>
