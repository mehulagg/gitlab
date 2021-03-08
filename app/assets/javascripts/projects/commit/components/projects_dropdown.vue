<script>
import {
  GlDropdown,
  GlSearchBoxByType,
  GlDropdownItem,
  GlDropdownText,
  GlLoadingIcon,
} from '@gitlab/ui';
import { mapActions, mapGetters, mapState } from 'vuex';
import { I18N_DROPDOWN } from '../constants';

export default {
  name: 'ProjectsDropdown',
  components: {
    GlDropdown,
    GlSearchBoxByType,
    GlDropdownItem,
    GlDropdownText,
    GlLoadingIcon,
  },
  props: {
    value: {
      type: String,
      required: false,
      default: '',
    },
  },
  i18n: I18N_DROPDOWN,
  data() {
    return {
      searchTerm: this.value,
    };
  },
  computed: {
    ...mapGetters(['joinedProjects']),
    ...mapState(['isFetching', 'project', 'projects']),
    filteredResults() {
      const lowerCasedSearchTerm = this.searchTerm.toLowerCase();
      return this.joinedProjects.filter((resultString) =>
        resultString.toLowerCase().includes(lowerCasedSearchTerm),
      );
    },
  },
  mounted() {
    this.fetchProjects(this.searchTerm);
  },
  methods: {
    ...mapActions(['fetchProjects']),
    selectProject(project) {
      this.$emit('selectProject', project);
      this.searchTerm = project; // enables isSelected to work as expected
    },
    isSelected(selectedProject) {
      return selectedProject === this.project;
    },
    searchTermChanged(value) {
      this.searchTerm = value;
      this.fetchProjects(value);
    },
  },
};
</script>
<template>
  <gl-dropdown :text="value" :header-text="$options.i18n.projectHeaderTitle">
    <gl-search-box-by-type
      :value="searchTerm"
      trim
      autocomplete="off"
      :debounce="250"
      :placeholder="$options.i18n.projectSearchPlaceholder"
      data-testid="dropdown-search-box"
      @input="searchTermChanged"
    />
    <gl-dropdown-item
      v-for="project in filteredResults"
      v-show="!isFetching"
      :key="project"
      :name="project"
      :is-checked="isSelected(project)"
      is-check-item
      data-testid="dropdown-item"
      @click="selectProject(project)"
    >
      {{ project }}
    </gl-dropdown-item>
    <gl-dropdown-text v-show="isFetching" data-testid="dropdown-text-loading-icon">
      <gl-loading-icon class="gl-mx-auto" />
    </gl-dropdown-text>
    <gl-dropdown-text
      v-if="!filteredResults.length && !isFetching"
      data-testid="empty-result-message"
    >
      <span class="gl-text-gray-500">{{ $options.i18n.noResultsMessage }}</span>
    </gl-dropdown-text>
  </gl-dropdown>
</template>
