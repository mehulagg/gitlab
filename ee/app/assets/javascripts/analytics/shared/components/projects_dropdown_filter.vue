<script>
import { debounce } from 'lodash';
import {
  GlIcon,
  GlLoadingIcon,
  GlAvatar,
  GlDropdown,
  GlDropdownSectionHeader,
  GlDropdownItem,
  GlSearchBoxByType,
} from '@gitlab/ui';
import { n__, s__, __ } from '~/locale';
import Api from '~/api';
import { DATA_REFETCH_DELAY } from '../constants';
import { filterBySearchTerm } from '../utils';
import getProjects from '../graphql/projects.query.graphql';

export default {
  name: 'ProjectsDropdownFilter',
  components: {
    GlIcon,
    GlLoadingIcon,
    GlAvatar,
    GlDropdown,
    GlDropdownSectionHeader,
    GlDropdownItem,
    GlSearchBoxByType,
  },
  props: {
    groupId: {
      type: Number,
      required: true,
    },
    groupNamespace: {
      type: String,
      required: true,
    },
    multiSelect: {
      type: Boolean,
      required: false,
      default: false,
    },
    label: {
      type: String,
      required: false,
      default: s__('CycleAnalytics|project dropdown filter'),
    },
    queryParams: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    defaultProjects: {
      type: Array,
      required: false,
      default: () => [],
    },
    useGraphql: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      loading: true,
      projects: [],
      selectedProjects: this.defaultProjects || [],
      searchTerm: '',
    };
  },
  computed: {
    selectedProjectsLabel() {
      if (this.selectedProjects.length === 1) {
        return this.selectedProjects[0].name;
      } else if (this.selectedProjects.length > 1) {
        return n__(
          'CycleAnalytics|Project selected',
          'CycleAnalytics|%d projects selected',
          this.selectedProjects.length,
        );
      }

      return this.selectedProjectsPlaceholder;
    },
    selectedProjectsPlaceholder() {
      return this.multiSelect ? __('Select projects') : __('Select a project');
    },
    isOnlyOneProjectSelected() {
      return this.selectedProjects.length === 1;
    },
    selectedProjectIds() {
      return this.selectedProjects.map(p => p.id);
    },
    availableProjects() {
      return filterBySearchTerm(this.projects, this.searchTerm);
    },
    noResultsAvailable() {
      const { loading, availableProjects } = this;
      return !loading && !availableProjects.length;
    },
  },
  watch: {
    searchTerm() {
      this.search();
    },
  },
  mounted() {
    this.search();
  },
  methods: {
    search: debounce(function debouncedSearch() {
      this.fetchData();
    }, DATA_REFETCH_DELAY),
    getSelectedProjects(selectedProject, isMarking) {
      return isMarking
        ? this.selectedProjects.concat([selectedProject])
        : this.selectedProjects.filter(project => project.id !== selectedProject.id);
    },
    singleSelectedProject(selectedObj, isMarking) {
      return isMarking ? [selectedObj] : [];
    },
    setSelectedProjects(selectedObj, isMarking) {
      this.selectedProjects = this.multiSelect
        ? this.getSelectedProjects(selectedObj, isMarking)
        : this.singleSelectedProject(selectedObj, isMarking);
    },
    onClick({ project, isSelected }) {
      this.setSelectedProjects(project, !isSelected);
      this.$emit('selected', this.selectedProjects);
    },
    fetchData() {
      this.loading = true;

      if (this.useGraphql) {
        return this.$apollo
          .query({
            query: getProjects,
            variables: {
              groupFullPath: this.groupNamespace,
              search: this.searchTerm,
              ...this.queryParams,
            },
          })
          .then(response => {
            const {
              data: {
                group: {
                  projects: { nodes },
                },
              },
            } = response;

            this.loading = false;
            this.projects = nodes.map(node => ({
              ...node,
              entityId: this.getEntityId(node),
            }));
          });
      }

      return Api.groupProjects(this.groupId, this.searchTerm, this.queryParams, projects => {
        this.projects = projects;
        this.loading = false;
      });
    },
    isProjectSelected(id) {
      return this.selectedProjects ? this.selectedProjectIds.includes(id) : false;
    },
    getEntityId(project) {
      const parts = project.id?.split('/') || [];
      return parts.length ? Number(parts.pop()) : 0;
    },
  },
};
</script>

<template>
  <gl-dropdown
    ref="projectsDropdown"
    class="dropdown dropdown-projects"
    toggle-class="gl-shadow-none"
  >
    <template #button-content>
      <div class="gl-display-flex gl-flex-fill-1">
        <gl-avatar
          v-if="isOnlyOneProjectSelected"
          :src="useGraphql ? selectedProjects[0].avatarUrl : selectedProjects[0].avatar_url"
          :entity-id="useGraphql ? selectedProjects[0].entityId : selectedProjects[0].id"
          :entity-name="selectedProjects[0].name"
          :size="16"
          shape="rect"
          :alt="selectedProjects[0].name"
          class="gl-display-inline-flex gl-vertical-align-middle gl-mr-2"
        />
        {{ selectedProjectsLabel }}
      </div>
      <gl-icon class="gl-ml-2" name="chevron-down" />
    </template>
    <gl-dropdown-section-header>{{ __('Projects') }}</gl-dropdown-section-header>
    <gl-search-box-by-type v-model.trim="searchTerm" class="gl-m-3" />

    <gl-dropdown-item
      v-for="project in availableProjects"
      :key="project.id"
      :is-check-item="true"
      :is-checked="isProjectSelected(project.id)"
      @click.prevent="onClick({ project, isSelected: isProjectSelected(project.id) })"
    >
      <div class="gl-display-flex">
        <gl-avatar
          class="gl-mr-2 vertical-align-middle"
          :alt="project.name"
          :size="16"
          :entity-id="useGraphql ? project.entityId : project.id"
          :entity-name="project.name"
          :src="useGraphql ? project.avatarUrl : project.avatar_url"
          shape="rect"
        />
        {{ project.name }}
      </div>
    </gl-dropdown-item>
    <gl-dropdown-item v-show="noResultsAvailable" class="gl-pointer-events-none text-secondary">{{
      __('No matching results')
    }}</gl-dropdown-item>
    <gl-dropdown-item v-if="loading">
      <gl-loading-icon size="lg" />
    </gl-dropdown-item>
  </gl-dropdown>
</template>
