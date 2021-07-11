<script>
import { GlLink, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { s__, sprintf } from '~/locale';
import ProjectAvatar from '~/vue_shared/components/deprecated_project_avatar/default.vue';
import { ALERT_THRESHOLD, ERROR_THRESHOLD, WARNING_THRESHOLD } from '../constants';
import { formatUsageSize, usageRatioToThresholdLevel } from '../utils';

export default {
  i18n: {
    warningWithNoPurchasedStorageText: s__(
      'UsageQuota|This project is near the free %{actualRepositorySizeLimit} limit and at risk of being locked.',
    ),
    lockedWithNoPurchasedStorageText: s__(
      'UsageQuota|This project is locked because it is using %{actualRepositorySizeLimit} of free storage and there is no purchased storage available.',
    ),
    warningWithPurchasedStorageText: s__(
      'UsageQuota|This project is at risk of being locked because purchased storage is running low.',
    ),
    lockedWithPurchasedStorageText: s__(
      'UsageQuota|This project is locked because it used %{actualRepositorySizeLimit} of free storage and all the purchased storage.',
    ),
  },
  components: {
    GlIcon,
    GlLink,
    ProjectAvatar,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    project: {
      required: true,
      type: Object,
    },
    additionalPurchasedStorageSize: {
      type: Number,
      required: true,
    },
  },
  computed: {
    projectAvatar() {
      const { name, id, avatarUrl, webUrl } = this.project;
      return {
        name,
        id: Number(getIdFromGraphQLId(id)),
        avatar_url: avatarUrl,
        path: webUrl,
      };
    },
    name() {
      return this.project.nameWithNamespace;
    },
    hasPurchasedStorage() {
      return this.additionalPurchasedStorageSize > 0;
    },
    storageSize() {
      return formatUsageSize(this.project.totalCalculatedUsedStorage);
    },
    excessStorageSize() {
      return formatUsageSize(this.project.repositorySizeExcess);
    },
    excessStorageRatio() {
      return this.project.totalCalculatedUsedStorage / this.project.totalCalculatedStorageLimit;
    },
    thresholdLevel() {
      return usageRatioToThresholdLevel(this.excessStorageRatio);
    },
    status() {
      const i18nTextOpts = {
        actualRepositorySizeLimit: formatUsageSize(this.project.actualRepositorySizeLimit),
      };
      if (this.thresholdLevel === ERROR_THRESHOLD) {
        const tooltipText = this.hasPurchasedStorage
          ? this.$options.i18n.lockedWithPurchasedStorageText
          : this.$options.i18n.lockedWithNoPurchasedStorageText;

        return {
          bgColor: { 'gl-bg-red-50': true },
          iconClass: { 'gl-text-red-500': true },
          linkClass: 'gl-text-red-500!',
          tooltipText: sprintf(tooltipText, i18nTextOpts),
        };
      } else if (
        this.thresholdLevel === WARNING_THRESHOLD ||
        this.thresholdLevel === ALERT_THRESHOLD
      ) {
        const tooltipText = this.hasPurchasedStorage
          ? this.$options.i18n.warningWithPurchasedStorageText
          : this.$options.i18n.warningWithNoPurchasedStorageText;

        return {
          bgColor: { 'gl-bg-orange-50': true },
          iconClass: 'gl-text-orange-500',
          tooltipText: sprintf(tooltipText, i18nTextOpts),
        };
      }

      return {};
    },
  },
};
</script>
<template>
  <div
    class="gl-responsive-table-row gl-border-solid gl-border-b-1 gl-pt-3 gl-pb-3 gl-border-b-gray-100"
    :class="status.bgColor"
    role="row"
    data-testid="projectTableRow"
  >
    <div
      class="table-section gl-white-space-normal! gl-sm-flex-wrap section-50 gl-text-truncate gl-pr-5"
      role="gridcell"
    >
      <div class="table-mobile-header gl-font-weight-bold" role="rowheader">
        {{ __('Project') }}
      </div>
      <div class="table-mobile-content gl-display-flex gl-align-items-center">
        <div class="gl-display-flex gl-mr-3 gl-ml-5 gl-align-items-center">
          <gl-icon name="bookmark" />
        </div>
        <div>
          <project-avatar :project="projectAvatar" :size="32" />
        </div>
        <div v-if="status.iconClass">
          <gl-icon
            v-gl-tooltip="{ title: status.tooltipText }"
            name="status_warning"
            class="gl-mr-3"
            :class="status.iconClass"
          />
        </div>
        <gl-link
          :href="project.webUrl"
          class="gl-font-weight-bold gl-text-gray-900!"
          :class="status.linkClass"
          >{{ name }}</gl-link
        >
      </div>
    </div>
    <div
      class="table-section gl-white-space-normal! gl-sm-flex-wrap section-15 gl-text-truncate"
      role="gridcell"
    >
      <div class="table-mobile-header gl-font-weight-bold" role="rowheader">
        {{ __('Usage') }}
      </div>
      <div class="table-mobile-content gl-text-gray-900">{{ storageSize }}</div>
    </div>
    <div
      class="table-section gl-white-space-normal! gl-sm-flex-wrap section-15 gl-text-truncate"
      role="gridcell"
    >
      <div class="table-mobile-header gl-font-weight-bold" role="rowheader">
        {{ __('Excess storage') }}
      </div>
      <div class="table-mobile-content gl-text-gray-900">{{ excessStorageSize }}</div>
    </div>
  </div>
</template>
