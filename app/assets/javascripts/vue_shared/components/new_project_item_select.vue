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
  },
};
</script>

<template>
  <gl-dropdown :text="text">
    <gl-search-box-by-type v-model.trim="searchTerm" />
    <gl-dropdown-item v-for="project in frequentProjects" :key="project.id">
      {{ project.name }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
