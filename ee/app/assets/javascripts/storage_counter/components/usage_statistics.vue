<script>
import { GlButton } from '@gitlab/ui';
import UsageStatisticsCard from './usage_statistics_card.vue';
import { s__ } from '~/locale';
import { formatUsageSize } from '../utils';

export default {
  components: {
    GlButton,
    UsageStatisticsCard,
  },
  props: {
    rootStorageStatistics: {
      required: true,
      type: Object,
    },
  },
  computed: {
    totalUsage() {
      return {
        usage: this.formatSize(this.rootStorageStatistics.totalRepositorySize),
        description: s__('UsageQuota|Total namespace storage used'),
      };
    },
    excessUsage() {
      return {
        usage: this.formatSize(this.rootStorageStatistics.totalRepositorySizeExcess),
        description: s__('UsageQuota|Total excess storage used'),
      };
    },
    purchasedUsage() {
      const {
        totalRepositorySizeExcess,
        additionalPurchasedStorageSize,
      } = this.rootStorageStatistics;
      return {
        usage: this.formatSize(
          Math.max(0, additionalPurchasedStorageSize - totalRepositorySizeExcess),
        ),
        usageTotal: this.formatSize(additionalPurchasedStorageSize),
        description: s__('UsageQuota|Purchased storage available'),
        link: {
          text: s__('UsageQuota|Purchase more storage'),
          url: '#',
        },
      };
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
    formatSize(size) {
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
    />
    <usage-statistics-card
      data-testid="excessUsage"
      :usage="excessUsage.usage"
      :link="excessUsage.link"
      :description="excessUsage.description"
      css-class="gl-mx-4"
    />
    <usage-statistics-card
      data-testid="purchasedUsage"
      :usage="purchasedUsage.usage"
      :usage-total="purchasedUsage.usageTotal"
      :link="purchasedUsage.link"
      :description="purchasedUsage.description"
      css-class="gl-ml-4"
    >
      <template #link="{link}">
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
