<script>
import { GlAlert, GlLoadingIcon, GlTab, GlTabs } from '@gitlab/ui';
import getStatesQuery from '../graphql/queries/get_states.query.graphql';

export default {
  apollo: {
    states: {
      query: getStatesQuery,
      variables() {
        return {
          projectPath: this.projectPath,
        };
      },
      update: data => data?.project?.terraformStates?.nodes,
    },
  },
  components: {
    GlAlert,
    GlLoadingIcon,
    GlTab,
    GlTabs,
  },
  props: {
    emptyStateImage: {
      required: true,
      type: String,
    },
    projectPath: {
      required: true,
      type: String,
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.states.loading;
    },
  },
};
</script>

<template>
  <section>
    <gl-tabs>
      <gl-tab :title="s__('Terraform|States')">
        <gl-loading-icon v-if="isLoading" size="md" class="gl-mt-3" />

        <div v-else-if="states" class="gl-mt-3">
          {{ s__('Terraform|States') }}
        </div>

        <gl-alert v-else variant="danger" :dismissible="false">
          {{ s__('Terraform|An error occurred while loading your Terraform States') }}
        </gl-alert>
      </gl-tab>
    </gl-tabs>
  </section>
</template>
