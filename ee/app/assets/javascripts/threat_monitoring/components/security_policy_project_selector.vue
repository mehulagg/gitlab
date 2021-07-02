<script>
import { GlAlert, GlButton, GlDropdown, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import AllProjectsSelector from '~/vue_shared/components/project_selector/all_projects_selector.vue';
import assignSecurityPolicyProject from '../graphql/mutations/assign_security_policy_project.mutation.graphql';

export default {
  PROJECT_SELECTOR_HEIGHT: 204,
  i18n: {
    assignError: s__(
      'SecurityOrchestration|An error has occured when assigning your security policy project',
    ),
    assignSuccess: s__('SecurityOrchestration|A security policy project was successfully linked'),
    securityProject: s__(
      'SecurityOrchestration|A security policy project can be used enforce policies for a given project, group, or instance. It allows you to specify security policies that are important to you  and enforce them with every commit. %{linkStart}More information%{linkEnd}',
    ),
  },
  components: {
    GlAlert,
    GlButton,
    GlDropdown,
    GlSprintf,
    AllProjectsSelector,
  },
  inject: ['documentationPath', 'projectPath'],
  props: {
    assignedPolicyProject: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      assignError: false,
      currentProjectId: this.assignedPolicyProject.id,
      isAssigningProject: false,
      selectedProjects: [this.assignedPolicyProject],
      showAssignSuccess: false,
    };
  },
  computed: {
    isNewProject() {
      return this.currentProjectId !== this.selectedProjects[0].id;
    },
  },
  methods: {
    dismissAlert(type) {
      this[type] = false;
    },
    async saveChanges() {
      this.isAssigningProject = true;
      const { id } = this.selectedProjects[0];
      try {
        const { data } = await this.$apollo.mutate({
          mutation: assignSecurityPolicyProject,
          variables: {
            projectPath: this.projectPath,
            securityPolicyProjectId: id,
          },
        });
        if (data?.securityPolicyProjectAssign?.errors?.length) {
          this.assignError = true;
        } else {
          this.showAssignSuccess = true;
          this.currentProjectId = id;
        }
      } catch (e) {
        this.assignError = true;
      } finally {
        this.isAssigningProject = false;
      }
    },
    updateSelectedProjects(selectedProject) {
      this.selectedProjects = [selectedProject];
      this.$refs.dropdown.hide(true);
    },
  },
};
</script>

<template>
  <section>
    <gl-alert
      v-if="assignError"
      class="gl-mt-3"
      data-testid="policy-project-assign-error"
      variant="danger"
      :dismissible="true"
      @dismiss="dismissAlert('assignError')"
    >
      {{ $options.i18n.assignError }}
    </gl-alert>
    <gl-alert
      v-else-if="showAssignSuccess"
      class="gl-mt-3"
      data-testid="policy-project-assign-success"
      variant="success"
      :dismissible="true"
      @dismiss="dismissAlert('showAssignSuccess')"
    >
      {{ $options.i18n.assignSuccess }}
    </gl-alert>
    <h2 class="gl-mb-8">
      {{ s__('SecurityOrchestration|Create a policy') }}
    </h2>
    <div class="gl-w-half">
      <h4>
        {{ s__('SecurityOrchestration|Security policy project') }}
      </h4>
      <gl-dropdown
        ref="dropdown"
        class="gl-w-full gl-pb-5 security-policy-dropdown"
        :text="selectedProjects[0].name"
      >
        <all-projects-selector
          class="gl-w-full"
          :max-list-height="$options.PROJECT_SELECTOR_HEIGHT"
          :selected-projects="selectedProjects"
          @projectClicked="updateSelectedProjects"
        />
      </gl-dropdown>
      <div class="gl-pb-5">
        <gl-sprintf :message="$options.i18n.securityProject">
          <template #link="{ content }">
            <gl-button class="gl-pb-1!" variant="link" :href="documentationPath" target="_blank">
              {{ content }}
            </gl-button>
          </template>
        </gl-sprintf>
      </div>
      <gl-button
        class="gl-display-block"
        data-testid="save-policy-project"
        variant="success"
        :disabled="!isNewProject"
        :loading="isAssigningProject"
        @click="saveChanges"
      >
        {{ __('Save changes') }}
      </gl-button>
    </div>
  </section>
</template>
