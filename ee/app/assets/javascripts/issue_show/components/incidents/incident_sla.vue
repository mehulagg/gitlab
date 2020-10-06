<script>
import createFlash from '~/flash';
import { s__ } from '~/locale';
import getSlaDueAt from './graphql/queries/get_sla_due_at.graphql';

export default {
  inject: ['fullPath', 'iid'],
  apollo: {
    slaDueAt: {
      query: getSlaDueAt,
      variables() {
        return {
          fullPath: this.fullPath,
          iid: this.iid,
        };
      },
      update(data) {
        return data?.project?.issue?.slaDueAt;
      },
      error() {
        createFlash({
          message: s__('Incident|There was an issue loading incident data. Please try again.'),
        });
      },
    },
  },
  data() {
    return {
      slaDueAt: 0,
    };
  },
  computed: {
    incidentSla() {
      return this.slaDueAt;
    },
  },
};
</script>

<template>
  <div v-show="slaDueAt !== null">
    <span class="gl-font-weight-bold">{{ s__('HighlightBar|SLA Due At:') }}</span>
    <span>{{ incidentSla }}</span>
  </div>
</template>
