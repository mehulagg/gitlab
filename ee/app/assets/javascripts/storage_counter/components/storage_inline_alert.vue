<script>
import { GlAlert } from '@gitlab/ui';
import { n__, __ } from '~/locale';
import { getFormatter, SUPPORTED_FORMATS } from '~/lib/utils/unit_format';
import { usageRatioToThresholdLevel } from '../usage_thresholds';
import { ALERT_THRESHOLD, ERROR_THRESHOLD, WARNING_THRESHOLD } from '../constants';

export default {
  components: {
    GlAlert,
  },
  props: {
    containsLockedProjects: {
      type: Boolean,
      required: true,
    },
    repositorySizeExcessProjectCount: {
      type: Number,
      required: true,
    },
    totalRepositorySizeExcess: {
      type: Number,
      required: true,
    },
    totalRepositorySize: {
      type: Number,
      required: true,
    },
    additionalPurchasedStorageSize: {
      type: Number,
      required: true,
    },
    repositoryFreeSizeLimit: {
      type: Number,
      required: true,
    },
  },
  computed: {
    shouldShowAlert() {
      return this.hasPurchasedStorage() || this.containsLockedProjects;
    },
    alertText() {
      return this.hasPurchasedStorage()
        ? this.hasPurchasedStorageText()
        : this.hasNotPurchasedStorageText();
    },
    alertTitle() {
      if (!this.hasPurchasedStorage() && this.containsLockedProjects) {
        return __('UsageQuota|This namespace contains locked projects');
      }
      return `${this.excessStoragePercentageLeft}% of purchased storage is available`;
    },
    excessStorageRatio() {
      return this.totalRepositorySizeExcess / this.additionalPurchasedStorageSize;
    },
    excessStoragePercentageUsed() {
      return (this.excessStorageRatio * 100).toFixed(0);
    },
    excessStoragePercentageLeft() {
      return Math.max(0, 100 - this.excessStoragePercentageUsed);
    },
    thresholdLevel() {
      return usageRatioToThresholdLevel(this.excessStorageRatio);
    },
    thresholdLevelToAlertVariant() {
      if (this.thresholdLevel === ERROR_THRESHOLD || this.thresholdLevel === ALERT_THRESHOLD) {
        return 'danger';
      } else if (this.thresholdLevel === WARNING_THRESHOLD) {
        return 'warning';
      }
      return 'info';
    },
    projectsLockedText() {
      if (this.repositorySizeExcessProjectCount === 0) {
        return '';
      }
      return `${this.repositorySizeExcessProjectCount} ${n__(
        'project',
        'projects',
        this.repositorySizeExcessProjectCount,
      )}`;
    },
  },
  methods: {
    hasPurchasedStorage() {
      return this.additionalPurchasedStorageSize > 0;
    },
    formatSize(size) {
      const formatter = getFormatter(SUPPORTED_FORMATS.decimalBytes);
      return formatter(size);
    },
    hasPurchasedStorageText() {
      if (this.thresholdLevel === ERROR_THRESHOLD) {
        return __(
          `You have consumed all of your additional storage, please purchase more to unlock your projects over the free ${this.formatSize(
            this.repositoryFreeSizeLimit,
          )} limit`,
        );
      } else if (
        this.thresholdLevel === WARNING_THRESHOLD ||
        this.thresholdLevel === ALERT_THRESHOLD
      ) {
        __(
          `Your purchased storage is running low. To avoid locked projects, please purchase more storage.`,
        );
      }
      return __(
        `When you purchase additional storage, we automatically unlock projects that were locked when you reached the ${this.formatSize(
          this.repositoryFreeSizeLimit,
        )} limit.`,
      );
    },
    hasNotPurchasedStorageText() {
      if (this.thresholdLevel === ERROR_THRESHOLD) {
        return __(
          `You have reached the free storage limit of ${this.formatSize(
            this.repositoryFreeSizeLimit,
          )} on ${this.projectsLockedText}. To unlock them, please purchase additional storage.`,
        );
      }
      return '';
    },
  },
};
</script>
<template>
  <gl-alert
    v-if="shouldShowAlert"
    class="gl-mt-5"
    :variant="thresholdLevelToAlertVariant"
    :dismissible="false"
    :title="alertTitle"
  >
    {{ alertText }}
  </gl-alert>
</template>
