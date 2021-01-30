<script>
import { GlCard } from '@gitlab/ui';
import RepoDropdown from './repo_dropdown.vue';
import RevisionDropdown from './revision_dropdown.vue';

export default {
  components: {
    RepoDropdown,
    RevisionDropdown,
    GlCard,
  },
  props: {
    refsProjectPath: {
      type: String,
      required: true,
    },
    revisionText: {
      type: String,
      required: true,
    },
    paramsName: {
      type: String,
      required: true,
    },
    paramsBranch: {
      type: String,
      required: false,
      default: null,
    },
  },
};
</script>

<template>
  <gl-card header-class="gl-py-2 gl-px-3" body-class="gl-px-3">
    <template #header>
      <div class="gl-font-weight-bold">
        {{ s__(`CompareRevisions|${revisionText}`) }}
      </div>
    </template>
    <div class="gl-sm-display-flex gl-align-items-center">
      <repo-dropdown :params-name="paramsName" />
      <revision-dropdown
        class="gl-mt-3 gl-sm-mt-0"
        :refs-project-path="refsProjectPath"
        :params-name="paramsName"
        :params-branch="paramsBranch"
      />
    </div>
  </gl-card>
</template>
