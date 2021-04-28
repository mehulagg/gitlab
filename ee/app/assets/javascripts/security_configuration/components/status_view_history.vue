<script>
import { GlLink } from '@gitlab/ui';
import StatusGeneric from './status_generic.vue';

export default {
  components: {
    GlLink,
    StatusGeneric,
  },
  props: {
    feature: {
      type: Object,
      required: true,
    },
    autoDevopsEnabled: {
      type: Boolean,
      required: true,
    },
    gitlabCiPresent: {
      type: Boolean,
      required: false,
      default: false,
    },
    gitlabCiHistoryPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    canViewCiHistory() {
      return this.feature.configured && this.gitlabCiPresent;
    },
  },
};
</script>

<template>
  <div>
    <status-generic :feature="feature" :auto-devops-enabled="autoDevopsEnabled" />

    <gl-link v-if="canViewCiHistory" :href="gitlabCiHistoryPath">{{
      s__('SecurityConfiguration|View history')
    }}</gl-link>
  </div>
</template>
