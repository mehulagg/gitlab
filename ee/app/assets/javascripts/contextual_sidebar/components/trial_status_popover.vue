<script>
import { GlButton, GlPopover, GlSprintf } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { debounce } from 'lodash';
import { formatDate } from '~/lib/utils/datetime_utility';
import { sprintf } from '~/locale';
import Tracking from '~/tracking';
import { POPOVER, RESIZE_EVENT, TRACKING_PROPERTY } from './constants';

const {
  i18n,
  trackingEvents,
  trialEndDateFormatString,
  resizeEventDebounceMS,
  disabledBreakpoints,
} = POPOVER;
const trackingMixin = Tracking.mixin({ property: TRACKING_PROPERTY });

export default {
  components: {
    GlButton,
    GlPopover,
    GlSprintf,
  },
  mixins: [trackingMixin],
  inject: {
    containerId: { default: null },
    groupName: {},
    planName: {},
    plansHref: {},
    purchaseHref: {},
    targetId: {},
    trialEndDate: {},
  },
  data() {
    return {
      disabled: false,
    };
  },
  i18n,
  trackingEvents,
  computed: {
    formattedTrialEndDate() {
      return formatDate(this.trialEndDate, trialEndDateFormatString);
    },
    upgradeButtonTitle() {
      return sprintf(this.$options.i18n.upgradeButtonTitle, {
        groupName: this.groupName,
        planName: this.planName,
      });
    },
  },
  created() {
    this.debouncedResize = debounce(() => this.onResize(), resizeEventDebounceMS);
    window.addEventListener(RESIZE_EVENT, this.debouncedResize);
  },
  mounted() {
    this.onResize();
  },
  beforeDestroy() {
    window.removeEventListener(RESIZE_EVENT, this.debouncedResize);
  },
  methods: {
    onResize() {
      this.updateDisabledState();
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
    updateDisabledState() {
      this.disabled = disabledBreakpoints.includes(bp.getBreakpointSize());
    },
  },
};
</script>

<template>
  <gl-popover
    :container="containerId"
    :target="targetId"
    :disabled="disabled"
    placement="rightbottom"
    boundary="viewport"
    :delay="{ hide: 400 }"
    @shown="onShown"
  >
    <template #title>
      {{ $options.i18n.popoverTitle }}
      <gl-emoji class="gl-vertical-align-baseline font-size-inherit gl-ml-1" data-name="wave" />
    </template>

    <gl-sprintf :message="$options.i18n.popoverContent">
      <template #bold="{ content }">
        <b>{{ sprintf(content, { trialEndDate: formattedTrialEndDate }) }}</b>
      </template>
      <template #planName>{{ planName }}</template>
    </gl-sprintf>

    <div class="gl-mt-5">
      <gl-button
        :href="purchaseHref"
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
        :href="plansHref"
        category="secondary"
        variant="confirm"
        size="small"
        class="gl-mb-0"
        block
        data-testid="compareBtn"
        :title="$options.i18n.compareAllButtonTitle"
        @click="onCompareBtnClick"
      >
        <span class="gl-font-sm">{{ $options.i18n.compareAllButtonTitle }}</span>
      </gl-button>
    </div>
  </gl-popover>
</template>
