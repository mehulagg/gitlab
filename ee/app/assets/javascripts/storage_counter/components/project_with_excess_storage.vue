<script>
/**
 * project_with_excess_storage.vue component is rendered behind
 * `additional_repo_storage_by_namespace` feature flag. The component
 * looks similar to project.vue component so that once the flag is
 * lifted this component could replace and be used mainstream.
 */
import { GlLink, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

export default {
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
    storageSize() {
      return numberToHumanSize(this.project.statistics.storageSize);
    },
    excessStorageSize() {
      return numberToHumanSize(this.project.statistics?.excessStorageSize ?? 0);
    },
    status() {
      // The project default limit will be sent by backend.
      // This is being added here just for testing purposes.
      // This entire component is rendered behind the
      // additional_repo_storage_by_namespace feature flag. This
      // piece will be removed along with the flag and the logic
      // will be mostly on the backend.
      const PROJECT_DEFAULT_LIMIT = 10000000000;
      const PROJECT_DEFAULT_WARNING_LIMIT = 9000000000;

      if (this.project.statistics.storageSize > PROJECT_DEFAULT_LIMIT) {
        return {
          bgColor: { 'gl-bg-red-50': true },
          iconClass: { 'gl-text-red-500': true },
          linkClass: 'gl-text-red-500!',
          tooltipText: s__('UsageQuota|This project is locked.'),
          needsAttn: true,
        };
      } else if (this.project.statistics.storageSize > PROJECT_DEFAULT_WARNING_LIMIT) {
        return {
          bgColor: { 'gl-bg-orange-50': true },
          iconClass: 'gl-text-orange-500',
          tooltipText: s__('UsageQuota|This project is at risk of being locked.'),
          needsAttn: true,
        };
      }

      return {
        bgColor: {},
        linkClass: {},
        needsAttn: false,
      };
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
      class="table-section gl-white-space-normal! gl-flex-sm-wrap section-50 gl-text-truncate"
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
        <div v-if="status.needsAttn">
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
      class="table-section gl-white-space-normal! gl-flex-sm-wrap section-25 gl-text-truncate"
      role="gridcell"
    >
      <div class="table-mobile-header gl-font-weight-bold" role="rowheader">
        {{ __('Usage') }}
      </div>
      <div class="table-mobile-content gl-text-gray-900">{{ storageSize }}</div>
    </div>
    <div
      class="table-section gl-white-space-normal! gl-flex-sm-wrap section-25 gl-text-truncate"
      role="gridcell"
    >
      <div class="table-mobile-header gl-font-weight-bold" role="rowheader">
        {{ __('Excess storage') }}
      </div>
      <div class="table-mobile-content gl-text-gray-900">{{ excessStorageSize }}</div>
    </div>
  </div>
</template>
