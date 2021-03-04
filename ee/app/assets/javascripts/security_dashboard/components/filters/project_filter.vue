<script>
import { GlDropdownDivider, GlSkeletonLoader, GlLoadingIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import { PROJECT_ID_PREFIX } from '../../constants';
import projectsFromIds from '../../graphql/queries/projects_from_ids.query.graphql';
import projectsSearch from '../../graphql/queries/group_projects_search.query.graphql';
import { mapProjects } from '../../helpers';
import FilterBody from './filter_body.vue';
import FilterItem from './filter_item.vue';
import StandardFilter from './standard_filter.vue';

export default {
  components: {
    FilterBody,
    FilterItem,
    GlDropdownDivider,
    GlSkeletonLoader,
    GlLoadingIcon,
  },
  extends: StandardFilter,
  props: {
    fullPath: { type: String, required: true },
  },
  data: () => ({
    preselectedProjects: [],
    projects: [],
    endCursor: undefined,
    hasDropdownBeenOpened: false,
  }),
  computed: {
    routeQueryOptions() {
      return this.routeQueryIds.map((x) => ({ id: x, name: '' }));
    },
    selectableProjects() {
      return this.projects.filter((x) => !this.preselectedProjects.includes(x.id));
    },
    isLoadingProjects() {
      return this.$apollo.queries.projects.loading;
    },
    isSearchTermValid() {
      return this.searchTerm.length <= 0 || this.searchTerm.length >= 3;
    },
  },
  apollo: {
    // This query is used to get project names from the project IDs in the querystring.
    preselectedProjects: {
      query: projectsFromIds,
      variables() {
        const ids = this.routeQueryIds.map((x) => `${PROJECT_ID_PREFIX}${x}`);
        return { ids };
      },
      update(data) {
        return mapProjects(data.project?.nodes);
      },
      error(error) {
        console.log('error', error);
        createFlash({
          message: 'some error occurred',
        });
      },
    },
    // This query gets the projects for the group/instance.
    projects: {
      query: projectsSearch,
      variables() {
        return {
          fullPath: this.fullPath,
          search: this.searchTerm,
        };
      },
      skip() {
        return !this.hasDropdownBeenOpened || !this.isSearchTermValid;
      },
      update(data) {
        console.log('data', data);
        this.endCursor = data.group?.projects.pageInfo.endCursor;
        console.log('setting endCursor to', this.endCursor);
        return mapProjects(data.group?.projects.nodes);
      },
    },
  },
  methods: {
    setDropdownOpened() {
      console.log('dropdown opened', this.endCursor);
      this.hasDropdownBeenOpened = true;
    },
  },
};
</script>

<template>
  <filter-body
    v-model.trim="searchTerm"
    :name="filter.name"
    :selected-options="selectedOptionsOrAll"
    :show-search-box="true"
    @dropdown-show="setDropdownOpened"
  >
    <template v-if="routeQueryOptions.length">
      <filter-item
        v-for="project in preselectedProjects"
        :key="project.id"
        :is-checked="true"
        :text="project.name"
      >
        <GlSkeletonLoader v-if="!project.name" :lines="1" />
      </filter-item>

      <gl-dropdown-divider />
    </template>

    <filter-item
      v-if="!searchTerm.length && !isLoadingProjects"
      :is-checked="isNoOptionsSelected"
      :text="filter.allOption.name"
      data-testid="allOption"
      @click="deselectAllOptions"
    />

    <template v-if="isSearchTermValid">
      <filter-item
        v-for="project in selectableProjects"
        :key="project.id"
        :is-checked="isSelected(project)"
        :text="project.name"
        @click="toggleOption(project)"
      />
    </template>
    <div v-else>
      {{ __('Enter at least three characters to search') }}
    </div>

    <gl-loading-icon v-if="isLoadingProjects" size="md" />
  </filter-body>
</template>
