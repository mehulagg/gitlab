<script>
import { GlButton } from '@gitlab/ui';
import UsageStatisticsCard from './usage_statistics_card.vue';
import { s__ } from '~/locale';
import { bytesToKB } from '~/lib/utils/number_utils';
import { getFormatter, SUPPORTED_FORMATS } from '~/lib/utils/unit_format';

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
      const { repositorySize = 0, lfsObjectsSize = 0 } = this.rootStorageStatistics;
      return {
        usage: this.formatSize(repositorySize + lfsObjectsSize),
        description: s__('UsageQuota|Total namespace storage used'),
        link: {
          text: s__('UsageQuota|Learn more about usage quotas'),
          url: '#',
        },
      };
    },
    excessUsage() {
      return {
        usage: this.formatSize(0),
        description: s__('UsageQuota|Total excess storage used'),
        link: {
          text: s__('UsageQuota|Learn more about excess storage usage'),
          url: '#',
        },
      };
    },
    purchasedUsage() {
      return {
        usage: this.formatSize(0),
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
     * The formatDecimalBytes method returns
     * value along with the unit. However, the unit
     * and the value needs to be separated so that
     * they can have different styles. The method
     * splits the value into value and unit.
     *
     * We want to display all units above bytes. Hence
     * converting bytesToKB before passing it to
     * `getFormatter`
     *
     * @params {Number} size size in bytes
     * @returns {Object} value and unit of formatted size
     */
    formatSize(size) {
      const formatDecimalBytes = getFormatter(SUPPORTED_FORMATS.kilobytes);
      const formattedSize = formatDecimalBytes(bytesToKB(size), 1);
      return {
        value: formattedSize.slice(0, -2),
        unit: formattedSize.slice(-2),
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
