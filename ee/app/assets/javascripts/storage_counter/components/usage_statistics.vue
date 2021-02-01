<script>
import { GlButton, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import { formatUsageSize } from '../utils';
import UsageStatisticsCard from './usage_statistics_card.vue';

export default {
  components: {
    GlButton,
    GlSprintf,
    UsageStatisticsCard,
  },
  props: {
    rootStorageStatistics: {
      required: true,
      type: Object,
    },
    purchaseStorageUrl: {
      required: false,
      type: String,
      default: '',
    },
  },
  computed: {
    formattedActualRepoSizeLimit() {
      return formatUsageSize(this.rootStorageStatistics.actualRepositorySizeLimit);
    },
    totalUsage() {
      return {
        usage: this.formatSizeAndSplit(this.rootStorageStatistics.totalRepositorySize),
        description: s__('UsageQuota|Total namespace storage used'),
        footerNote: s__(
          'UsageQuota|This is the total amount of storage used across your projects within this namespace.',
        ),
      };
    },
    excessUsage() {
      return {
        usage: this.formatSizeAndSplit(this.rootStorageStatistics.totalRepositorySizeExcess),
        description: s__('UsageQuota|Total excess storage used'),
        footerNote: s__(
          'UsageQuota|This is the total amount of storage used by projects above the free %{actualRepositorySizeLimit} storage limit.',
        ),
      };
    },
    purchasedUsage() {
      const {
        totalRepositorySizeExcess,
        additionalPurchasedStorageSize,
      } = this.rootStorageStatistics;
      return this.purchaseStorageUrl
        ? {
            usage: this.formatSizeAndSplit(
              Math.max(0, additionalPurchasedStorageSize - totalRepositorySizeExcess),
            ),
            usageTotal: this.formatSizeAndSplit(additionalPurchasedStorageSize),
            description: s__('UsageQuota|Purchased storage available'),
            link: {
              text: s__('UsageQuota|Purchase more storage'),
              url: this.purchaseStorageUrl,
            },
          }
        : null;
    },
  },
  methods: {
    /**
     * The formatUsageSize method returns
     * value along with the unit. However, the unit
     * and the value needs to be separated so that
     * they can have different styles. The method
     * splits the value into value and unit.
     *
     * @params {Number} size size in bytes
     * @returns {Object} value and unit of formatted size
     */
    formatSizeAndSplit(size) {
      const formattedSize = formatUsageSize(size);
      return {
        value: formattedSize.slice(0, -3),
        unit: formattedSize.slice(-3),
      };
    },
  },
};
</script>
<template>
  <div class="gl-display-flex gl-sm-flex-direction-column">
    <usage-statistics-card
      data-testid="totalUsage"
      :usage="totalUsage.usage"
      :link="totalUsage.link"
      :description="totalUsage.description"
      css-class="gl-mr-4"
    >
      <template #footer="{}">
        {{ totalUsage.footerNote }}
      </template>
    </usage-statistics-card>
    <usage-statistics-card
      data-testid="excessUsage"
      :usage="excessUsage.usage"
      :link="excessUsage.link"
      :description="excessUsage.description"
      css-class="gl-mx-4"
    >
      <template #footer="{}">
        <gl-sprintf :message="excessUsage.footerNote">
          <template #actualRepositorySizeLimit>
            {{ formattedActualRepoSizeLimit }}
          </template>
        </gl-sprintf>
      </template>
    </usage-statistics-card>
    <usage-statistics-card
      v-if="purchasedUsage"
      data-testid="purchasedUsage"
      :usage="purchasedUsage.usage"
      :usage-total="purchasedUsage.usageTotal"
      :link="purchasedUsage.link"
      :description="purchasedUsage.description"
      css-class="gl-ml-4"
    >
      <template #footer="{ link }">
        <gl-button
          target="_blank"
          :href="link.url"
          class="mb-0"
          variant="success"
          category="primary"
          block
        >
          {{ link.text }}
        </gl-button>
      </template>
    </usage-statistics-card>
  </div>
</template>
