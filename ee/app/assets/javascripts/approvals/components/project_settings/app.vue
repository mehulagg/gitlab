<script>
import App from '../app.vue';
import ProjectRules from './project_rules.vue';

export default {
  components: {
    App,
    ProjectRules,
  },
};
</script>

<template>
  <app :is-mr-edit="false">
    <template #rules>
      <project-rules />
    </template>
  </app>
</template>
