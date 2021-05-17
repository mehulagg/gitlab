<script>
import { GlTable } from '@gitlab/ui';
import { __, s__ } from '~/locale';

const defaultTableClasses = {
  tdClass: 'gl-p-5!',
  thClass: 'gl-bg-transparent! gl-border-b-solid! gl-border-b-gray-100! gl-p-5! gl-border-b-1!',
};

export default {
  i18n: {
    emptyText: s__('CI/CD|No projects have been added to the scope'),
  },
  fields: [
    {
      key: 'project',
      label: __('Project'),
      ...defaultTableClasses,
      columnClass: 'gl-w-85p',
    },
    {
      key: 'actions',
      label: '',
      ...defaultTableClasses,
      columnClass: 'gl-w-15p',
    },
  ],
  components: {
    GlTable,
  },
  data() {
    return {
      projects: [],
    };
  },
};
</script>
<template>
  <gl-table
    :items="projects"
    :fields="$options.fields"
    :tbody-tr-attr="{ 'data-testid': 'ci-cd-projects-token-table-row' }"
    :empty-text="$options.i18n.emptyText"
    show-empty
    stacked="lg"
    fixed
  >
    <template #cell(project)="{ item }">
      <span>>{{ item }}</span>
    </template>
    <template #cell(actions)="{ item }">
      <!--TODO: Change this to a button-->
      <span>>{{ item }}</span>
    </template>
  </gl-table>
</template>
