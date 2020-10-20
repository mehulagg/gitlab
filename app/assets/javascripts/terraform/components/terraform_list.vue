<script>
import { GlTab, GlTabs } from '@gitlab/ui';
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
};
</script>

<template>
  <section>
    <gl-tabs>
      <gl-tab :title="s__('Terraform|States')">
        <p>{{ s__('Terraform|Table Content') }}</p>
      </gl-tab>
    </gl-tabs>
  </section>
</template>
