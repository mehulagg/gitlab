<script>
import { GlAlert } from '@gitlab/ui';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  name: 'JiraConnectApp',
  components: {
    GlAlert,
  },
  mixins: [glFeatureFlagsMixin()],
  computed: {
    state() {
      return this.$root.$data.state || {};
    },
    error() {
      return this.state.error;
    },
    showNewUi() {
      return this.glFeatures.newJiraConnectUi;
    },
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="error" variant="danger" :dismissible="false">
      {{ error }}
    </gl-alert>

    <div v-if="showNewUi">
      <h3>{{ s__('Integrations|Linked namespaces') }}</h3>
    </div>
  </div>
</template>
