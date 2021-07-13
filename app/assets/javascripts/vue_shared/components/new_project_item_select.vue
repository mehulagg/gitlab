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
    }
  },
  computed: {
    text() {
      return `Create ${this.label.toLowerCase()} in...`
    },
    filteredProjectNames() {
      return this.frequentProjects.filter(project => project.name.toLowerCase().includes(this.searchTerm.toLowerCase())).sort((a, b) => b.lastAccessedOn - a.lastAccessedOn);
    },
    filteredProjectNamesLength() {
      return this.filteredProjectNames.length === 0;
    },
  },
  mounted() {
    return console.log(this.filteredProjectNames, 'filtered names')
  }
};
</script>

<template>
  <gl-dropdown :text="text">
    <gl-search-box-by-type v-model.trim="searchTerm" />
    <gl-dropdown-item v-for="project in filteredProjectNames" :key="project.id" >
      {{ project.name }}
    </gl-dropdown-item>
    <div v-show="filteredProjectNamesLength" class="text-secondary p-2">Nothing found…</div>
  </gl-dropdown>
</template>
