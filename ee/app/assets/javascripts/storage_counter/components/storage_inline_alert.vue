<script>
import { GlAlert } from '@gitlab/ui';
import { __ } from '~/locale';
import { numberToHumanSize, MiBToBytes } from '~/lib/utils/number_utils';
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
    lockedProjectCount: {
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
      return this.hasPurchasedStorage || this.containsLockedProjects;
    },
    alertText() {
      return this.hasPurchasedStorage
        ? this.hasPurchasedStorageText()
        : this.hasNotPurchasedStorageText();
    },
    excessStoragePercentageUsed() {
      return ((this.totalRepositorySizeExcess / this.additionalPurchasedStorageSize) * 100).toFixed(
        0,
      );
    },
    thresholdLevel() {
      return usageRatioToThresholdLevel(this.excessStoragePercentageUsed);
    },
    thresholdLevelToAlertVariant() {
      if (this.thresholdLevel === ERROR_THRESHOLD || this.thresholdLevel === ALERT_THRESHOLD) {
        return 'danger';
      } else if (this.thresholdLevel === WARNING_THRESHOLD) {
        return 'warning';
      }
      return 'info';
    },
  },
  methods: {
    hasPurchasedStorage() {
      return this.additionalPurchasedStorageSize > 0;
    },
    formatSize(size) {
      return numberToHumanSize(size);
    },
    formatMiBSize(size) {
      // MiB or MB?
      return numberToHumanSize(MiBToBytes(size));
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
        )}`,
      );
    },
    hasNotPurchasedStorageText() {
      if (this.thresholdLevel === ERROR_THRESHOLD) {
        return __(
          `You have reached the free storage limit of ${this.formatSize(
            this.repositoryFreeSizeLimit,
          )} on ${this.lockedProjectCount}. To unlock them, please purchase additional storage.`,
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
  >
    {{ alertText }}
  </gl-alert>
</template>