<script>
import {
  GlDropdown,
  GlDropdownItem,
  GlDropdownSectionHeader,
  GlDropdownDivider,
  GlIcon,
  GlSearchBoxByType,
} from '@gitlab/ui';

// TODO: add feature flag and test

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlDropdownSectionHeader,
    GlDropdownDivider,
    GlIcon,
    GlSearchBoxByType,
  },
  props: {
  },
  data() {
    return {
      currentBranch: 'main',
      // TODO: get from graphql
      branches: ['production', 'staging', 'beta', 'test'],
      // TODO: filter options
      searchTerm: '',
    };
  },
  computed: {
  },
  methods: {
    switchToBranch(branch) {
      window.location.href = `${window.location.href}?branch_name=${branch}`;
    }
  },
};
</script>

<template>
  <gl-dropdown
    class="gl-ml-2"
    :text="currentBranch"
    header-text="Switch Branch"
  >
   <gl-search-box-by-type v-model="searchTerm" />
    <gl-dropdown-section-header>
      Branches
    </gl-dropdown-section-header>
    <gl-dropdown-item>
      <gl-icon name="check" />
      {{ currentBranch }}
    </gl-dropdown-item>
    <gl-dropdown-item
      v-for="branch in branches"
      :key="branch"
      @click="switchToBranch(branch)"
    >
      <gl-icon name="check" class="gl-visibility-hidden" />
      {{ branch }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
