<script>
import { s__ } from '~/locale';
import IntegrationView from './integration_view.vue';

const INTEGRATION_VIEW_CONFIGS = {
  sourcegraph: {
    title: s__('ProfilePreferences|Sourcegraph'),
    label: s__('ProfilePreferences|Enable integrated code intelligence on code views'),
    formName: 'sourcegraph_enabled',
  },
  gitpod: {
    title: s__('ProfilePreferences|Gitpod'),
    label: s__('ProfilePreferences|Enable Gitpod integration'),
    formName: 'gitpod_enabled',
  },
};

export default {
  name: 'ProfilePreferences',
  components: {
    IntegrationView,
  },
  props: {
    integrationViews: {
      type: Array,
      required: false,
      default: () => [],
    },
    userFields: {
      type: Object,
      required: true,
    },
  },
  integrationViewConfigs: INTEGRATION_VIEW_CONFIGS,
};
</script>

<template>
  <div class="row">
    <div v-if="integrationViews.length" class="col-sm-12">
      <hr />
    </div>
    <div v-if="integrationViews.length" class="col-lg-4 profile-settings-sidebar">
      <h4 class="gl-mt-0">
        {{ s__('ProfilePreferences|Integrations') }}
      </h4>
      <p>
        {{ s__('ProfilePreferences|Customize integrations with third party services.') }}
      </p>
    </div>
    <div v-if="integrationViews.length" class="col-lg-8">
      <integration-view
        v-for="view in integrationViews"
        :key="view.name"
        :help-link="view.help_link"
        :message="view.message"
        :message-url="view.message_url"
        :user-fields="userFields"
        :config="$options.integrationViewConfigs[view.name]"
      />
    </div>
  </div>
</template>
