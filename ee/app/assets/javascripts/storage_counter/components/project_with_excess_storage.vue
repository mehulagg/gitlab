<script>
/**
 * project_with_excess_storage.vue component is rendered behind
 * `additional_repo_storage_by_namespace` feature flag. The component
 * looks similar to project.vue component so that once the flag is
 * lifted this component could replace and be used mainstream.
 */
import { GlLink, GlIcon } from '@gitlab/ui';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

export default {
  components: {
    GlIcon,
    GlLink,
    ProjectAvatar,
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
    hasError() {
      // The project default limit will be sent by backend.
      // This is being added here just for testing purposes.
      // This entire component is rendered behind the
      // additional_repo_storage_by_namespace feature flag. This
      // piece will be removed along with the flag.
      const PROJECT_DEFAULT_LIMIT = 10000000000;
      const projectLimit = this.project.statistics?.projectLimit ?? PROJECT_DEFAULT_LIMIT;
      return this.project.statistics.storageSize > projectLimit;
    },
  },
};
</script>
<template>
  <div
    class="gl-responsive-table-row gl-border-solid gl-border-b-1 gl-pt-3 gl-pb-3 gl-border-b-gray-100"
    :class="{ 'gl-bg-red-50': hasError }"
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
        <div v-if="hasError">
          <gl-icon name="status_warning" class="gl-text-red-500 gl-mr-3" />
        </div>
        <gl-link
          :href="project.webUrl"
          class="js-project-link gl-font-weight-bold gl-text-gray-900!"
          :class="{ 'gl-text-red-500!': hasError }"
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
