<script>
import { GlPopover, GlSprintf } from '@gitlab/ui';
import { toNumber } from 'lodash';
import StackedProgressBar from '~/vue_shared/components/stacked_progress_bar.vue';

export default {
  name: 'GeoNodeSyncProgress',
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
  },
};
</script>

<template>
  <div>
    <stacked-progress-bar
      :id="`syncProgress-${title}`"
      tabindex="0"
      hide-tooltips
      :unavailable-label="s__('Geo|Nothing to synchronize')"
      :success-count="successCount"
      :failure-count="failureCount"
      :total-count="totalCount"
    />
    <gl-popover
      :target="`syncProgress-${title}`"
      placement="right"
      triggers="hover focus"
      :css-classes="['w-100']"
    >
      <template #title>
        <gl-sprintf :message="s__('Geo|Number of %{title}')">
          <template #title>
            {{ title }}
          </template>
        </gl-sprintf>
      </template>
      <section>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-transparent gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ s__('Geo|Total') }}</span>
          <span class="gl-font-weight-bold">{{ totalCount.toLocaleString() }}</span>
        </div>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-green-500 gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ s__('Geo|Synced') }}</span>
          <span class="gl-font-weight-bold">{{ successCount.toLocaleString() }}</span>
        </div>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-gray-200 gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ s__('Geo|Queued') }}</span>
          <span class="gl-font-weight-bold">{{ queuedCount.toLocaleString() }}</span>
        </div>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-red-500 gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ s__('Geo|Failed') }}</span>
          <span class="gl-font-weight-bold">{{ failureCount.toLocaleString() }}</span>
        </div>
      </section>
    </gl-popover>
  </div>
</template>
