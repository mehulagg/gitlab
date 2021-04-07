<script>
import { GlButton, GlPopover, GlSprintf } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { debounce } from 'lodash';
import { formatDate } from '~/lib/utils/datetime_utility';
import { s__ } from '~/locale';
import Tracking from '~/tracking';

const RESIZE_EVENT_DEBOUNCE_MS = 150;

export default {
  tracking: {
    event: 'click_button',
    labels: { upgrade: 'upgrade_to_ultimate', compare: 'compare_all_plans' },
    property: 'experiment:show_trial_status_in_sidebar',
  },
  components: {
    GlButton,
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
    groupName: {
      type: String,
      required: true,
    },
    planName: {
      type: String,
      required: true,
    },
    plansHref: {
      type: String,
      required: true,
    },
    purchaseHref: {
      type: String,
      required: true,
    },
    targetId: {
      type: String,
      required: true,
    },
    trialEndDate: {
      type: Date,
      required: true,
    },
  },
  data() {
    return {
      disabled: false,
    };
  },
  i18n: {
    compareAllButtonTitle: s__('Trials|Compare all plans'),
    popoverTitle: s__('Trials|Hey there'),
    popoverContent: s__(`Trials|Your trial ends on
      %{boldStart}%{trialEndDate}%{boldEnd}. We hope you’re enjoying the
      features of GitLab %{planName}. To keep those features after your trial
      ends, you’ll need to buy a subscription. (You can also choose GitLab
      Premium if it meets your needs.)`),
    upgradeButtonTitle: s__('Trials|Upgrade %{groupName} to %{planName}'),
  },
  computed: {
    formattedTrialEndDate() {
      return formatDate(this.trialEndDate, 'mmmm d');
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
        label: 'trial_status_popover',
        property: 'experiment:show_trial_status_in_sidebar',
      });
    },
    updateDisabledState() {
      this.disabled = ['xs', 'sm'].includes(bp.getBreakpointSize());
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
        :data-track-event="$options.tracking.event"
        :data-track-label="$options.tracking.labels.upgrade"
        :data-track-property="$options.tracking.property"
      >
        <span class="gl-font-sm">
          <gl-sprintf :message="$options.i18n.upgradeButtonTitle">
            <template #groupName>{{ groupName }}</template>
            <template #planName>{{ planName }}</template>
          </gl-sprintf>
        </span>
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
        :data-track-event="$options.tracking.event"
        :data-track-label="$options.tracking.labels.compare"
        :data-track-property="$options.tracking.property"
      >
        <span class="gl-font-sm">{{ $options.i18n.compareAllButtonTitle }}</span>
      </gl-button>
    </div>
  </gl-popover>
</template>
