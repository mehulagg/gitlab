<script>
import { GlButton, GlLink, GlIcon } from '@gitlab/ui';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import { numberToHumanSize, isOdd } from '~/lib/utils/number_utils';
import { s__ } from '~/locale';
import StorageRow from './storage_row.vue';

export default {
  components: {
    GlIcon,
    GlButton,
    GlLink,
    ProjectAvatar,
    StorageRow,
  },
  props: {
    project: {
      required: true,
      type: Object,
    },
  },
  data() {
    return {
      isOpen: false,
    };
  },
  computed: {
    projectAvatar() {
      const { name, id, avatarUrl, webUrl } = this.project;
      return {
        name,
        id: Number(id),
        avatar_url: avatarUrl,
        path: webUrl,
      };
    },
    name() {
      return this.project.nameWithNamespace;
    },
    storageSize() {
      return numberToHumanSize(this.project.statistics.storageSize);
    },
    iconName() {
      return this.isOpen ? 'angle-down' : 'angle-right';
    },
    statistics() {
      const statisticsCopy = { ...this.project.statistics };
      delete statisticsCopy.storageSize;
      // eslint-disable-next-line no-underscore-dangle
      delete statisticsCopy.__typename;
      delete statisticsCopy.commitCount;

      return statisticsCopy;
    },
  },
  methods: {
    toggleProject() {
      this.isOpen = !this.isOpen;
    },
    getFormattedName(name) {
      return this.$options.i18nStatisticsMap[name];
    },
    isOdd(num) {
      return isOdd(num);
    },
    /**
     * Some values can be `nil`
     * for those, we send 0 instead
     */
    getValue(val) {
      return val || 0;
    },
  },
  i18nStatisticsMap: {
    repositorySize: s__('UsageQuota|Repository'),
    lfsObjectsSize: s__('UsageQuota|LFS Storage'),
    buildArtifactsSize: s__('UsageQuota|Artifacts'),
    packagesSize: s__('UsageQuota|Packages'),
    wikiSize: s__('UsageQuota|Wiki'),
    snippetsSize: s__('UsageQuota|Snippets'),
  },
};
</script>
<template>
  <div>
    <div class="gl-responsive-table-row border-bottom" role="row">
      <div class="table-section section-wrap section-70 text-truncate" role="gridcell">
        <div class="table-mobile-header font-weight-bold" role="rowheader">{{ __('Project') }}</div>
        <div class="table-mobile-content">
          <gl-button
            class="btn-transparent float-left p-0 mr-2"
            :aria-label="__('Toggle project')"
            category="tertiary"
            @click="toggleProject"
          >
            <gl-icon :name="iconName" class="folder-icon" />
          </gl-button>

          <project-avatar :project="projectAvatar" :size="20" />

          <gl-link :href="project.webUrl" class="font-weight-bold">{{ name }}</gl-link>
        </div>
      </div>
      <div class="table-section section-wrap section-30 text-truncate" role="gridcell">
        <div class="table-mobile-header font-weight-bold" role="rowheader">{{ __('Usage') }}</div>
        <div class="table-mobile-content">{{ storageSize }}</div>
      </div>
    </div>

    <template v-if="isOpen">
      <storage-row
        v-for="(value, statisticsName, index) in statistics"
        :key="index"
        :name="getFormattedName(statisticsName)"
        :value="getValue(value)"
        :class="{ 'bg-gray-light': isOdd(index) }"
      />
    </template>
  </div>
</template>
