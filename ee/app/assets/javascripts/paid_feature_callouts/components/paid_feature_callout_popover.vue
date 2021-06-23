<script>
import { GlButton, GlPopover } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { debounce } from 'lodash';
import { sprintf } from '~/locale';
import Tracking from '~/tracking';
import {
  POPOVER,
  EXPERIMENT_KEY,
  POPOVER_OR_TOOLTIP_BREAKPOINT,
  RESIZE_EVENT_DEBOUNCE_MS,
} from '../constants';

const { i18n, trackingEvents } = POPOVER;
const trackingMixin = Tracking.mixin({ experiment: EXPERIMENT_KEY });

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
      default: i18n.defaultImgAltText,
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
  i18n,
  trackingEvents,
  computed: {
    title() {
      return sprintf(this.$options.i18n.title.countableTranslator(this.daysRemaining), {
        daysRemaining: this.daysRemaining,
        featureName: this.featureName,
      });
    },
    content() {
      return sprintf(this.$options.i18n.content, {
        featureName: this.featureName,
        planNameForTrial: this.planNameForTrial,
        planNameForUpgrade: this.planNameForUpgrade,
      });
    },
    upgradeButtonLabel() {
      return sprintf(this.$options.i18n.buttons.upgrade, {
        planNameForUpgrade: this.planNameForUpgrade,
      });
    },
    comparePlansButtonLabel() {
      return this.$options.i18n.buttons.comparePlans;
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
      this.disabled = bp.getBreakpointSize() === POPOVER_OR_TOOLTIP_BREAKPOINT;
    },
    onShown() {
      const { action, ...options } = this.$options.trackingEvents.popoverShown;
      this.track(action, { ...options, label: `${options.label}:${this.featureName}` });
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
    <template #title>{{ title }}</template>

    <div v-if="promoImagePath" class="gl-display-flex gl-justify-content-center gl-mt-n3 gl-mb-4">
      <img
        :src="promoImagePath"
        :alt="promoImageAltText"
        height="40"
        width="40"
        data-testid="promo-img"
      />
    </div>

    {{ content }}

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
        <span class="gl-font-sm">{{ upgradeButtonLabel }}</span>
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
        <span class="gl-font-sm">{{ comparePlansButtonLabel }}</span>
      </gl-button>
    </div>
  </gl-popover>
</template>
