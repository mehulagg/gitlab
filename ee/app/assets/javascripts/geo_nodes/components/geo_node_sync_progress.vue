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
    itemTitle: {
      type: String,
      required: true,
    },
    itemValue: {
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
      return toNumber(this.itemValue.totalCount) || 0;
    },
    failureCount() {
      return toNumber(this.itemValue.failureCount) || 0;
    },
    successCount() {
      return toNumber(this.itemValue.successCount) || 0;
    },
  },
};
</script>

<template>
  <div>
    <stacked-progress-bar
      :id="`syncProgress-${itemTitle}`"
      tabindex="0"
      :hide-tooltips="true"
      :unavailable-label="__('Nothing to synchronize')"
      :success-count="successCount"
      :failure-count="failureCount"
      :total-count="totalCount"
    />
    <gl-popover :target="`syncProgress-${itemTitle}`" placement="right" :css-classes="['w-100']">
      <template #title>
        <gl-sprintf :message="__('Number of %{itemTitle}')">
          <template #itemTitle>
            {{ itemTitle }}
          </template>
        </gl-sprintf>
      </template>
      <section>
        <div class="d-flex align-items-center my-1">
          <div class="mr-2 bg-transparent gl-w-5 gl-h-2"></div>
          <span class="flex-grow-1 mr-3">{{ __('Total') }}</span>
          <span class="font-weight-bold">{{ totalCount.toLocaleString() }}</span>
        </div>
        <div class="d-flex align-items-center my-2">
          <div class="mr-2 bg-success-500 gl-w-5 gl-h-2"></div>
          <span class="flex-grow-1 mr-3">{{ __('Synced') }}</span>
          <span class="font-weight-bold">{{ successCount.toLocaleString() }}</span>
        </div>
        <div class="d-flex align-items-center my-2">
          <div class="mr-2 bg-secondary-200 gl-w-5 gl-h-2"></div>
          <span class="flex-grow-1 mr-3">{{ __('Queued') }}</span>
          <span class="font-weight-bold">{{ queuedCount.toLocaleString() }}</span>
        </div>
        <div class="d-flex align-items-center my-2">
          <div class="mr-2 bg-danger-500 gl-w-5 gl-h-2"></div>
          <span class="flex-grow-1 mr-3">{{ __('Failed') }}</span>
          <span class="font-weight-bold">{{ failureCount.toLocaleString() }}</span>
        </div>
        <div v-if="detailsPath" class="mt-3">
          <gl-link class="gl-font-sm" :href="detailsPath" target="_blank">{{
            __('More information')
          }}</gl-link>
        </div>
      </section>
    </gl-popover>
  </div>
</template>
