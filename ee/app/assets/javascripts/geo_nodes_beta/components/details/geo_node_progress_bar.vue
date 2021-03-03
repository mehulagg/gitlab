<script>
import { GlPopover, GlSprintf, GlLink } from '@gitlab/ui';
import { toNumber } from 'lodash';
import StackedProgressBar from '~/vue_shared/components/stacked_progress_bar.vue';

export default {
  name: 'GeoNodeSyncProgress',
  components: {
    GlPopover,
    GlSprintf,
    GlLink,
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
    detailsPath: {
      type: String,
      required: false,
      default: '',
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
      :unavailable-label="__('Nothing to synchronize')"
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
        <gl-sprintf :message="__('Number of %{title}')">
          <template #title>
            {{ title }}
          </template>
        </gl-sprintf>
      </template>
      <section>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-transparent gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ __('Total') }}</span>
          <span class="gl-font-weight-bold">{{ totalCount.toLocaleString() }}</span>
        </div>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-green-500 gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ __('Synced') }}</span>
          <span class="gl-font-weight-bold">{{ successCount.toLocaleString() }}</span>
        </div>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-gray-200 gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ __('Queued') }}</span>
          <span class="gl-font-weight-bold">{{ queuedCount.toLocaleString() }}</span>
        </div>
        <div class="gl-display-flex gl-align-items-center gl-my-3">
          <div class="gl-mr-3 gl-bg-red-500 gl-w-5 gl-h-2"></div>
          <span class="gl-flex-fill-1 gl-mr-4">{{ __('Failed') }}</span>
          <span class="gl-font-weight-bold">{{ failureCount.toLocaleString() }}</span>
        </div>
        <div v-if="detailsPath" class="mt-3">
          <gl-link class="gl-font-sm" :href="detailsPath" target="_blank">{{
            __('Learn more')
          }}</gl-link>
        </div>
      </section>
    </gl-popover>
  </div>
</template>
