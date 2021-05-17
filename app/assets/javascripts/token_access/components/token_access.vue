<script>
import { GlButton, GlCard, GlFormGroup, GlFormInput, GlToggle } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import TokenProjectsTable from './token_projects_table.vue';

export default {
  i18n: {
    toggleLabelTitle: s__('CICD|Limit CI_JOB_TOKEN access'),
    toggleHelpText: s__(
      `CICD|Manage which projects can use this project's CI_JOB_TOKEN CI/CD variable for API access`,
    ),
    cardHeaderTitle: s__('CICD|Add an existing project to the scope'),
    formGroupLabel: __('Search for project'),
    addProject: __('Add project'),
    cancel: __('Cancel'),
    saveChanges: __('Save changes'),
  },
  components: {
    GlButton,
    GlCard,
    GlFormGroup,
    GlFormInput,
    GlToggle,
    TokenProjectsTable,
  },
  data() {
    return {
      tokenEnabled: false,
      projectUrl: '',
    };
  },
};
</script>
<template>
  <div>
    <gl-toggle
      v-model="tokenEnabled"
      :label="$options.i18n.toggleLabelTitle"
      :help="$options.i18n.toggleHelpText"
    />
    <div v-if="tokenEnabled">
      <token-projects-table />
      <gl-card class="gl-mt-5">
        <template #header>
          <strong ref="title">{{ $options.i18n.cardHeaderTitle }}</strong>
        </template>
        <template #default>
          <gl-form-group :label="formGroupLabel">
            <gl-form-input v-model="projectUrl" />
          </gl-form-group>
        </template>
        <template #footer>
          <div class="gl-display-flex gl-justify-content-space-between">
            <gl-button variant="confirm">{{ $options.i18n.addProject }}</gl-button>
            <gl-button>{{ $options.i18n.cancel }}</gl-button>
          </div>
        </template>
      </gl-card>
      <gl-button class="gl-mt-5" variant="confirm">{{ $options.i18n.saveChanges }}</gl-button>
    </div>
  </div>
</template>
