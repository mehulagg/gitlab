<script>
import { GlDropdown, GlDropdownItem, GlSearchBoxByType } from '@gitlab/ui';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
  },
  inject: ['projectTo', 'projectsFrom'],
  props: {
    paramsName: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      searchTerm: '',
      selectedRepo: {},
    };
  },
  computed: {
    filteredRepos() {
      return this.targetProjects.filter(({ name }) =>
        name.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    },
    targetProjects() {
      return JSON.parse(this.projectsFrom);
    },
    isSourceRevision() {
      return this.paramsName === 'to';
    },
  },
  mounted() {
    this.setDefaultRepo();
  },
  methods: {
    onClick(repo) {
      this.selectedRepo = repo;
      this.emitTargetProject(repo.name);
    },
    setSelectedRepo(project) {
      this.selectedRepo = project;
    },
    setDefaultRepo() {
      const projectJson = this.isSourceRevision ? this.projectTo : this.projectsFrom;
      const project = JSON.parse(projectJson);

      if (this.isSourceRevision) {
        this.selectedRepo = project;
        return;
      }

      const defaultTargetProject = project[0];
      this.emitTargetProject(defaultTargetProject.name);
      this.selectedRepo = defaultTargetProject;
    },
    emitTargetProject(name) {
      if (!this.isSourceRevision) {
        this.$emit('changeTargetProject', name);
      }
    },
  },
};
</script>

<template>
  <div class="compare-form-group">
    <input type="hidden" :name="`${paramsName}_project_id`" :value="selectedRepo.id" />
    <gl-dropdown
      :text="selectedRepo.name"
      header-text="Select target project"
      class="gl-w-full gl-font-monospace gl-sm-pr-3"
      toggle-class="gl-min-w-0"
      :disabled="isSourceRevision"
    >
      <template #header>
        <gl-search-box-by-type v-if="!isSourceRevision" v-model.trim="searchTerm" />
      </template>
      <div v-if="!isSourceRevision">
        <gl-dropdown-item
          v-for="repo in filteredRepos"
          :key="repo.id"
          is-check-item
          :is-checked="selectedRepo.id === repo.id"
          @click="onClick(repo)"
        >
          {{ repo.name }}
        </gl-dropdown-item>
      </div>
    </gl-dropdown>
  </div>
</template>
