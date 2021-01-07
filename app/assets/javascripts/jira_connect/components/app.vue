<script>
import { GlAlert } from '@gitlab/ui';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { store } from '../store';

export default {
  name: 'JiraConnectApp',
  components: {
    GlAlert,
  },
  mixins: [glFeatureFlagsMixin()],
  computed: {
    errorMessage() {
      return store.errorMessage;
    },
    showNewUi() {
      return this.glFeatures.newJiraConnectUi;
    },
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="errorMessage" class="gl-mb-6" variant="danger" :dismissible="false">
      {{ errorMessage }}
    </gl-alert>

    <div v-if="showNewUi">
      <h3 data-testid="new-jira-connect-ui-heading">{{ s__('Integrations|Linked namespaces') }}</h3>
    </div>
  </div>
</template>
