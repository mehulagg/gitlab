<script>
import { GlDropdown, GlDropdownItem, GlDropdownSectionHeader, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import getAvailableBranches from '~/pipeline_editor/graphql/queries/available_branches.graphql';
import getCurrentBranch from '~/pipeline_editor/graphql/queries/client/current_branch.graphql';

export default {
  i18n: {
    title: s__('PipelineEditor|Branches'),
  },
  components: {
    GlDropdown,
    GlDropdownItem,
    GlDropdownSectionHeader,
    GlIcon,
  },
  inject: ['projectFullPath'],
  apollo: {
    branches: {
      query: getAvailableBranches,
      variables() {
        return {
          projectFullPath: this.projectFullPath,
        };
      },
      update: (data) => {
        return data.project?.repository?.branches || [];
      },
      error() {
        this.hasError = true;
      },
    },
    currentBranch: {
      query: getCurrentBranch,
    },
  },
  computed: {
    hasBranchList() {
      return this.branches?.length > 1;
    },
    branchListWithoutCurrentBranch() {
      return this.branches.filter((branch) => branch.name !== this.currentBranch);
    },
  },
  methods: {
    selectBranch(branchName) {
      this.$emit('switchBranch', branchName);
    },
  },
};
</script>

<template>
  <gl-dropdown v-if="hasBranchList" class="gl-ml-2" :text="currentBranch" icon="branch">
    <gl-dropdown-section-header>
      {{ this.$options.i18n.title }}
    </gl-dropdown-section-header>
    <gl-dropdown-item>
      <gl-icon name="check" />
      {{ currentBranch }}
    </gl-dropdown-item>
    <gl-dropdown-item
      v-for="branch in branchListWithoutCurrentBranch"
      :key="branch.name"
      @click="selectBranch(branch.name)"
    >
      <gl-icon name="check" class="gl-visibility-hidden" />
      {{ branch.name }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
