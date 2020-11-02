<script>
import { s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { fetchPolicies } from '~/lib/graphql';
import createFlash from '~/flash';
import getIntegrationsQuery from '../graphql/queries/get_integrations.query.graphql';
import createHttpIntegrationMutation from '../graphql/mutations/create_http_integration.mutation.graphql';
import createPrometheusIntegrationMutation from '../graphql/mutations/create_prometheus_integration.mutation.graphql';
import updateHttpIntegrationMutation from '../graphql/mutations/update_http_integration.mutation.graphql';
import updatePrometheusIntegrationMutation from '../graphql/mutations/update_prometheus_integration.mutation.graphql';
import resetHttpTokenMutation from '../graphql/mutations/reset_http_token.mutation.graphql';
import resetPrometheusTokenMutation from '../graphql/mutations/reset_prometheus_token.mutation.graphql';
import IntegrationsList from './alerts_integrations_list.vue';
import SettingsFormOld from './alerts_settings_form_old.vue';
import SettingsFormNew from './alerts_settings_form_new.vue';

export default {
  components: {
    IntegrationsList,
    SettingsFormOld,
    SettingsFormNew,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: {
    generic: {
      default: {},
    },
    prometheus: {
      default: {},
    },
    projectPath: {
      default: '',
    },
  },
  apollo: {
    integrations: {
      fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
      query: getIntegrationsQuery,
      variables() {
        return {
          projectPath: this.projectPath,
        };
      },
      update(data) {
        const { alertManagementIntegrations: { nodes: list = [] } = {} } = data.project || {};

        return {
          list,
        };
      },
      error() {
        this.errored = true;
      },
    },
  },
  data() {
    return {
      errored: false,
      isUpdating: false,
      integrations: {},
      currentIntegration: null,
    };
  },
  computed: {
    loading() {
      return this.$apollo.queries.integrations.loading;
    },
    intergrationsOptionsOld() {
      return [
        {
          name: s__('AlertSettings|HTTP endpoint'),
          type: s__('AlertsIntegrations|HTTP endpoint'),
          active: this.generic.active,
        },
        {
          name: s__('AlertSettings|External Prometheus'),
          type: s__('AlertsIntegrations|Prometheus'),
          active: this.prometheus.active,
        },
      ];
    },
  },
  methods: {
    onCreateNewIntegration({ type, variables }) {
      this.isUpdating = true;
      this.$apollo
        .mutate({
          mutation:
            type === 'HTTP' ? createHttpIntegrationMutation : createPrometheusIntegrationMutation,
          variables: {
            ...variables,
            projectPath: this.projectPath,
          },
        })
        .then(({ data: { httpIntegrationCreate, prometheusIntegrationCreate } = {} } = {}) => {
          // TODO: Handle ee or user recoverable errors via generic handler here
          // eslint-disable-next-line no-console
          console.debug(httpIntegrationCreate, prometheusIntegrationCreate);
        })
        .catch(err => {
          this.errored = true;
          createFlash({ message: err });
        })
        .finally(() => {
          this.isUpdating = false;
        });
    },
    onUpdateIntegration({ type, variables }) {
      this.isUpdating = true;
      this.$apollo
        .mutate({
          mutation:
            type === 'HTTP' ? updateHttpIntegrationMutation : updatePrometheusIntegrationMutation,
          variables: {
            ...variables,
            projectPath: this.projectPath,
          },
        })
        .then(({ data: { httpIntegrationUpdate, prometheusIntegrationUpdate } = {} } = {}) => {
          // TODO: Handle ee or user recoverable errors via generic handler here
          // eslint-disable-next-line no-console
          console.debug(httpIntegrationUpdate, prometheusIntegrationUpdate);
        })
        .catch(err => {
          this.errored = true;
          createFlash({ message: err });
        })
        .finally(() => {
          this.isUpdating = false;
        });
    },
    onResetToken({ type, variables }) {
      this.isUpdating = true;
      this.$apollo
        .mutate({
          mutation: type === 'HTTP' ? resetHttpTokenMutation : resetPrometheusTokenMutation,
          variables,
        })
        .then(
          ({ data: { httpIntegrationResetToken, prometheusIntegrationResetToken } = {} } = {}) => {
            // TODO: Handle ee or user recoverable errors via generic handler here
            // eslint-disable-next-line no-console
            console.debug(httpIntegrationResetToken, prometheusIntegrationResetToken);
          },
        )
        .catch(err => {
          this.errored = true;
          createFlash({ message: err });
        })
        .finally(() => {
          this.isUpdating = false;
        });
    },
    onEditIntegration({ id }) {
      this.currentIntegration = this.integrations.find(integration => integration.id === id);
    },
    onDeleteIntegration() {
      // TODO, handle delete via GraphQL
    },
  },
};
</script>

<template>
  <div>
    <integrations-list
      :integrations="glFeatures.httpIntegrationsList ? integrations.list : intergrationsOptionsOld"
      :loading="loading"
      @on-edit-integration="onEditIntegration"
      @on-delete-integration="onDeleteIntegration"
    />
    <settings-form-new
      v-if="glFeatures.httpIntegrationsList"
      :loading="isUpdating"
      :current-integration="currentIntegration"
      @on-create-new-integration="onCreateNewIntegration"
      @on-update-integration="onUpdateIntegration"
      @on-reset-token="onResetToken"
    />
    <settings-form-old v-else />
  </div>
</template>
