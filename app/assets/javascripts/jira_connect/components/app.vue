<script>
import { GlButton, GlModal, GlModalDirective } from '@gitlab/ui';
import { __ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import GroupsList from './groups_list.vue';

export default {
  name: 'JiraConnectApp',
  components: {
    GlButton,
    GlModal,
    GroupsList,
  },
  directives: {
    GlModalDirective,
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
  modal: {
    cancelProps: {
      text: __('Cancel'),
    },
  },
};
</script>

<template>
  <div>
    <div
      v-if="showNewUi"
      class="gl-display-flex gl-justify-content-space-between gl-mt-5 gl-mb-5 gl-pb-4 gl-border-b-solid gl-border-b-1 gl-border-b-gray-200"
    >
      <h3>{{ s__('Integrations|Linked namespaces') }}</h3>
      <gl-button
        v-gl-modal-directive="'add-namespace-modal'"
        category="primary"
        variant="info"
        class="gl-align-self-center"
        >{{ s__('Integrations|Add namespace') }}</gl-button
      >
      <gl-modal
        modal-id="add-namespace-modal"
        :title="s__('Integrations|Link namespaces')"
        :action-cancel="$options.modal.cancelProps"
      >
        <groups-list />
      </gl-modal>
    </div>
  </div>
</template>
