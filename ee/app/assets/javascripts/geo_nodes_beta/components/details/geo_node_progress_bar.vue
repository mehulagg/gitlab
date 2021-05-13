<script>
import { GlPopover, GlSprintf } from '@gitlab/ui';
import { toNumber } from 'lodash';
import { __, s__ } from '~/locale';
import StackedProgressBar from '~/vue_shared/components/stacked_progress_bar.vue';

export default {
  name: 'GeoNodeSyncProgress',
  i18n: {
    unavailableLabel: s__('Geo|Nothing to synchronize'),
    popoverTitle: s__('Geo|Number of %{title}'),
    total: __('Total'),
    synced: s__('Geo|Synced'),
    queued: s__('Geo|Queued'),
    failed: __('Failed'),
  },
  components: {
    GlPopover,
    GlSprintf,
    StackedProgressBar,
  },
  props: {
    title: {
      type: String,
      required: true,
    },
    values: {
      type: Object,
      required: true,
    },
    target: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    queuedCount() {
      return this.totalCount - this.successCount - this.failureCount;
    },
    totalCount() {
      return toNumber(this.values.total) || 0;
    },
    failureCount() {
      return toNumber(this.values.failed) || 0;
    },
    successCount() {
      return toNumber(this.values.success) || 0;
    },
    popoverTarget() {
      return this.target ? this.target : `syncProgress-${this.title}`;
    },
  },
};
</script>

<template>
  <div>
    <stacked-progress-bar
      :id="popoverTarget"
      tabindex="0"
      hide-tooltips
      :unavailable-label="$options.i18n.unavailableLabel"
      :success-count="successCount"
      :failure-count="failureCount"
      :total-count="totalCount"
    />
    <gl-popover
      :target="popoverTarget"
      placement="right"
      triggers="hover focus"
      :css-classes="['w-100']"
    >
      <template #title>
        <gl-sprintf :message="$options.i18n.popoverTitle">
          <template #title>
            {{ title }}
          </template>
        </gl-sprintf>
      </template>
      <section>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-transparent gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ $options.i18n.total }}</span>
          <span class="gl-font-weight-bold">{{ totalCount.toLocaleString() }}</span>
        </div>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-green-500 gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ $options.i18n.synced }}</span>
          <span class="gl-font-weight-bold">{{ successCount.toLocaleString() }}</span>
        </div>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-gray-200 gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ $options.i18n.queued }}</span>
          <span class="gl-font-weight-bold">{{ queuedCount.toLocaleString() }}</span>
        </div>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-red-500 gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ $options.i18n.failed }}</span>
          <span class="gl-font-weight-bold">{{ failureCount.toLocaleString() }}</span>
        </div>
      </section>
    </gl-popover>
  </div>
</template>
