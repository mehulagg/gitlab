<script>
import { debounce } from 'lodash';
import {
  GlDropdown,
  GlDropdownItem,
  GlDropdownText,
  GlSearchBoxByType,
  GlLoadingIcon,
} from '@gitlab/ui';
import eventHub from '../eventhub';
import { s__ } from '~/locale';
import Api from '../../api';
import { featureAccessLevel } from '~/pages/projects/shared/permissions/constants';

const debounceDelay = 250;

export default {
  name: 'ProjectSelect',
  i18n: {
    headerTitle: s__(`BoardNewIssue|Projects`),
    dropdownText: s__(`BoardNewIssue|Select a project`),
    emptySearchResult: s__(`BoardNewIssue|No matching results`),
  },
  defaultFetchOptions: {
    with_issues_enabled: true,
    with_shared: false,
    include_subgroups: true,
    order_by: 'similarity',
  },
  components: {
    GlLoadingIcon,
    GlDropdown,
    GlDropdownItem,
    GlDropdownText,
    GlSearchBoxByType,
  },
  props: {
    list: {
      type: Object,
      required: true,
    },
  },
  inject: ['groupId'],
  data() {
    return {
      initialLoading: false,
      isFetching: false,
      projects: [],
      selectedProject: {},
      searchTerm: '',
    };
  },
  computed: {
    selectedProjectName() {
      return this.selectedProject.name || this.$options.i18n.dropdownText;
    },
    fetchOptions() {
      const additionalAttrs = {};
      if (this.list.type && this.list.type !== 'backlog') {
        additionalAttrs.min_access_level = featureAccessLevel.EVERYONE;
      }

      return {
        ...this.$options.defaultFetchOptions,
        ...additionalAttrs,
      };
    },
    isFetchResultEmpty() {
      return this.projects.length === 0;
    },
  },
  async mounted() {
    this.initialLoading = true;

    await this.fetchProjects();

    this.initialLoading = false;
  },
  methods: {
    async fetchProjects() {
      this.isFetching = true;
      try {
        const projects = await Api.groupProjects(this.groupId, this.searchTerm, this.fetchOptions);

        this.projects = projects.map(project => {
          return {
            id: project.id,
            name: project.name,
            namespacedName: project.name_with_namespace,
            path: project.path_with_namespace,
          };
        });
      } finally {
        this.isFetching = false;
      }
    },
    debouncedFetch: debounce(function debounceWrapper() {
      this.fetchProjects();
    }, debounceDelay),
    selectProject(projectId) {
      this.selectedProject = this.projects.find(project => project.id === projectId);

      /*
        TODO Remove eventhub, use Vuex for BoardNewIssue and GraphQL for BoardNewIssueNew
        https://gitlab.com/gitlab-org/gitlab/-/issues/276173
      */
      eventHub.$emit('setSelectedProject', this.selectedProject);
    },
  },
};
</script>

<template>
  <div>
    <label class="gl-font-weight-bold gl-mt-3">{{ $options.i18n.headerTitle }}</label>
    <gl-dropdown
      data-testid="project-select-dropdown"
      :text="selectedProjectName"
      :header-text="$options.i18n.headerTitle"
      block
      menu-class="w-100"
      :loading="initialLoading"
    >
      <gl-search-box-by-type
        v-model.trim="searchTerm"
        class="gl-sticky gl-top-0 gl-z-index-3"
        @input="debouncedFetch"
      />
      <gl-dropdown-item
        v-for="project in projects"
        v-show="!isFetching"
        :key="project.id"
        :name="project.name"
        @click="selectProject(project.id)"
      >
        {{ project.namespacedName }}
      </gl-dropdown-item>
      <gl-dropdown-text v-show="isFetching">
        <gl-loading-icon class="gl-mx-auto" />
      </gl-dropdown-text>
      <gl-dropdown-text v-if="isFetchResultEmpty">
        <span class="text-secondary">{{ $options.i18n.emptySearchResult }}</span>
      </gl-dropdown-text>
    </gl-dropdown>
  </div>
</template>
