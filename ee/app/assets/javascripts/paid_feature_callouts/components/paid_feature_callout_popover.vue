<script>
import { GlButton, GlPopover } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { debounce } from 'lodash';
import { __, n__, s__, sprintf } from '~/locale';
import Tracking from '~/tracking';

const RESIZE_EVENT_DEBOUNCE_MS = 150;
const CLICK_BUTTON = 'click_button';
const trackingMixin = Tracking.mixin({ experiment: 'highlight_paid_features_during_active_trial' });

export default {
  components: {
    GlButton,
    GlPopover,
  },
  mixins: [trackingMixin],
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
    hrefComparePlans: {
      type: String,
      required: true,
    },
    hrefUpgradeToPaid: {
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
    promoImageAltText: {
      type: String,
      required: false,
      default: __('SVG illustration'),
    },
    promoImagePath: {
      type: String,
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
    compareAllButtonTitle: s__('BillingPlans|Compare all plans'),
  },
  trackingEvents: {
    popoverShown: { action: 'popover_shown', label: 'feature_highlight_popover' },
    upgradeBtnClick: { action: CLICK_BUTTON, label: 'upgrade_to_premium' },
    compareBtnClick: { action: CLICK_BUTTON, label: 'compare_all_plans' },
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
    upgradeButtonTitle() {
      const i18nUpgradeButtonTitle = s__('BillingPlans|Upgrade to GitLab %{planNameForUpgrade}');

      return sprintf(i18nUpgradeButtonTitle, {
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
    updateDisabledState() {
      this.disabled = bp.getBreakpointSize() === 'xs';
    },
    onShown() {
      const { action, ...options } = this.$options.trackingEvents.popoverShown;
      this.track(action, options);
    },
    onUpgradeBtnClick() {
      const { action, ...options } = this.$options.trackingEvents.upgradeBtnClick;
      this.track(action, options);
    },
    onCompareBtnClick() {
      const { action, ...options } = this.$options.trackingEvents.compareBtnClick;
      this.track(action, options);
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

    <div v-if="promoImagePath" class="gl-display-flex gl-justify-content-center gl-mt-n3 gl-mb-4">
      <img
        :src="promoImagePath"
        :alt="promoImageAltText"
        height="40"
        width="40"
        data-testid="promo-img"
      />
    </div>

    {{ popoverContent }}

    <div class="gl-mt-5">
      <gl-button
        :href="hrefUpgradeToPaid"
        target="_blank"
        category="primary"
        variant="confirm"
        size="small"
        class="gl-mb-0"
        block
        data-testid="upgradeBtn"
        @click="onUpgradeBtnClick"
      >
        <span class="gl-font-sm">{{ upgradeButtonTitle }}</span>
      </gl-button>
      <gl-button
        :href="hrefComparePlans"
        target="_blank"
        category="secondary"
        variant="confirm"
        size="small"
        class="gl-mb-0"
        block
        data-testid="compareBtn"
        @click="onCompareBtnClick"
      >
        <span class="gl-font-sm">{{ $options.i18n.compareAllButtonTitle }}</span>
      </gl-button>
    </div>
  </gl-popover>
</template>
