<script>
import { GlButton } from '@gitlab/ui';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';

export default {
  components: {
    GlButton,
    ProjectSelector,
  },
  inject: ['documentationPath'],
  props: {
    project: {
      type: String,
      required: true,
    },
    selectProjectPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    projectSearchResults() {
      return [];
    },
    selectedProjects() {
      return [];
    },
  },
  methods: {
    fetchSearchResults(data) {
      console.log('fet', data);
    },
    saveChanges() {
      console.log('saved');
    },
    searched(data) {
      console.log('searched', data);
    },
    toggleSelectedProject(data) {
      console.log('togg', data);
    },
  },
};
</script>

<template>
  <section>
    <h2 class="gl-mb-8">
      {{ s__('SecurityOrchestration|Create a policy') }}
    </h2>
    <h4>
      {{ s__('SecurityOrchestration|Security policy project') }}
    </h4>
    <project-selector
      :project-search-results="projectSearchResults"
      :selected-projects="selectedProjects"
      @searched="searched"
      @projectClicked="toggleSelectedProject"
      @bottomReached="fetchSearchResults"
    />
    <div class="text-muted">
      {{
        s__(
          'SecurityOrchestration|A security policy project can be used enforce policies for a given project, group, or instance. It allows you to specify security policies that are important to you  and enforce them with every commit.',
        )
      }}
    </div>
    <gl-link :href="$options.TAKING_INCIDENT_ACTION_DOCS_LINK" target="_blank">
      {{ __('More information') }}
    </gl-link>
    <gl-button data-testid="cancelAddNewColumn" @click="saveChanges">{{
      __('Save changes')
    }}</gl-button>
  </section>
</template>
