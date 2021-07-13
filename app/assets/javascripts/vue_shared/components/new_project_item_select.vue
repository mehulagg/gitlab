<script>
import { GlDropdown, GlDropdownItem, GlSearchBoxByType } from '@gitlab/ui';

export default {
  name: 'NewProjectItemSelect',
  components: {
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
  },
  props: {
    type: {
      type: String,
      required: false,
      default: '',
    },
    path: {
      type: String,
      required: false,
      default: '',
    },
    with_feature_enabled: {
      type: String,
      required: false,
      default: '',
    },
    label: {
      type: String,
      required: false,
      default: '',
    },
    frequentProjects: {
      type: Array,
      required: false,
    },
  },
  data() {
    return {
      searchTerm: '',
    };
  },
  computed: {
    text() {
      return `Create ${this.label.toLowerCase()}`;
    },
    filteredProjectNames() {
      return this.frequentProjects
        .filter((project) =>
          project.namespace.toLowerCase().includes(this.searchTerm.toLowerCase()),
        )
        .sort((a, b) => b.lastAccessedOn - a.lastAccessedOn);
    },
    filteredProjectNamesLength() {
      return this.filteredProjectNames.length === 0;
    },
  },
  mounted() {
    return console.log(this.filteredProjectNames, 'filtered names');
  },
};
</script>

<template>
  <gl-dropdown variant="confirm" :text="text" header-text="Recent projects" right>
    <template #header>
      <gl-search-box-by-type v-model.trim="searchTerm" />
    </template>
    <gl-dropdown-item
      v-for="project in filteredProjectNames"
      :key="project.id"
      :href="`${project.webUrl}/-/${path}`"
    >
      {{ project.namespace }}
    </gl-dropdown-item>
    <div v-show="filteredProjectNamesLength" class="text-secondary p-2">No projects found…</div>
  </gl-dropdown>
</template>
