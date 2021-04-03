<script>
import { isEmpty } from 'lodash';

import Approval from './statuses/approval.vue';
import Pipeline from './statuses/pipeline.vue';

export default {
  components: {
    Approval,
    Pipeline,
  },
  props: {
    status: {
      type: Object,
      required: true,
    },
  },
  computed: {
    hasData() {
      return !isEmpty(this.status.data);
    },
  },
};
</script>

<template>
  <div
    class="gl-display-flex gl-align-items-center gl-justify-content-center gl-border-b-solid gl-border-b-1 gl-border-b-gray-100 gl-p-5"
  >
    <component :is="status.type" v-if="hasData" :status="status.data" />
  </div>
</template>
