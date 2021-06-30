<script>
import { GlTable, GlEmptyState, GlButton, GlAlert, GlSprintf, GlLink } from '@gitlab/ui';
import { mapState, mapGetters } from 'vuex';
import { PREDEFINED_NETWORK_POLICIES } from 'ee/threat_monitoring/constants';
import createFlash from '~/flash';
import { getTimeago } from '~/lib/utils/datetime_utility';
import { setUrlFragment, mergeUrlParams } from '~/lib/utils/url_utility';
import { s__ } from '~/locale';
import networkPoliciesQuery from '../graphql/queries/network_policies.query.graphql';
import scanExecutionPoliciesQuery from '../graphql/queries/scan_execution_policies.query.graphql';
import EnvironmentPicker from './environment_picker.vue';
import PolicyDrawer from './policy_drawer/policy_drawer.vue';

const createPolicyFetchError = ({ gqlError, networkError }) => {
  const error =
    gqlError?.message ||
    networkError?.message ||
    s__('NetworkPolicies|Something went wrong, unable to fetch policies');
  createFlash({
    message: error,
  });
};

export default {
  components: {
    GlTable,
    GlEmptyState,
    GlButton,
    GlAlert,
    GlSprintf,
    GlLink,
    EnvironmentPicker,
    PolicyDrawer,
  },
  inject: ['projectPath'],
  props: {
    documentationPath: {
      type: String,
      required: true,
    },
    newPolicyPath: {
      type: String,
      required: true,
    },
  },
  apollo: {
    networkPolicies: {
      query: networkPoliciesQuery,
      variables() {
        return {
          fullPath: this.projectPath,
          environmentId: this.allEnvironments ? null : this.currentEnvironmentGid,
        };
      },
      update(data) {
        const policies = data?.project?.networkPolicies?.nodes ?? [];
        const predefined = PREDEFINED_NETWORK_POLICIES.filter(
          ({ name }) => !policies.some((policy) => name === policy.name),
        );
        return [...policies, ...predefined];
      },
      error: createPolicyFetchError,
      skip() {
        return this.isLoadingEnvironments;
      },
    },
    scanExecutionPolicies: {
      query: scanExecutionPoliciesQuery,
      variables() {
        return {
          fullPath: this.projectPath,
        };
      },
      update(data) {
        return data?.project?.scanExecutionPolicies?.nodes ?? [];
      },
      error: createPolicyFetchError,
    },
  },
  data() {
    return {
      selectedPolicyName: null,
      initialManifest: null,
      initialEnforcementStatus: null,
      networkPolicies: [],
      scanExecutionPolicies: [],
    };
  },
  computed: {
    ...mapState('threatMonitoring', [
      'currentEnvironmentId',
      'allEnvironments',
      'isLoadingEnvironments',
    ]),
    ...mapGetters('threatMonitoring', ['currentEnvironmentGid']),
    documentationFullPath() {
      return setUrlFragment(this.documentationPath, 'container-network-policy');
    },
    policies() {
      return [...this.networkPolicies, ...this.scanExecutionPolicies];
    },
    isLoadingPolicies() {
      return (
        this.isLoadingEnvironments ||
        this.$apollo.queries.networkPolicies.loading ||
        this.$apollo.queries.scanExecutionPolicies.loading
      );
    },
    hasSelectedPolicy() {
      return Boolean(this.selectedPolicyName);
    },
    selectedPolicy() {
      if (!this.hasSelectedPolicy) return null;
      return this.networkPolicies.find((policy) => policy.name === this.selectedPolicyName);
    },
    hasAutoDevopsPolicy() {
      return Boolean(this.networkPolicies?.some((policy) => policy.fromAutoDevops));
    },
    editPolicyPath() {
      return this.hasSelectedPolicy
        ? mergeUrlParams(
            { environment_id: this.currentEnvironmentId },
            this.newPolicyPath.replace('new', `${this.selectedPolicyName}/edit`),
          )
        : '';
    },
    fields() {
      const namespace = {
        key: 'namespace',
        label: s__('NetworkPolicies|Namespace'),
      };
      const fields = [
        {
          key: 'name',
          label: s__('NetworkPolicies|Name'),
          thClass: 'gl-w-half',
        },
        {
          key: 'status',
          label: s__('NetworkPolicies|Status'),
        },
        {
          key: 'updatedAt',
          label: s__('NetworkPolicies|Last modified'),
        },
      ];
      // Adds column 'namespace' only while 'all environments' option is selected
      if (this.allEnvironments) fields.splice(1, 0, namespace);

      return fields;
    },
  },
  methods: {
    getTimeAgoString(updatedAt) {
      if (!updatedAt) return '';
      return getTimeago().format(updatedAt);
    },
    presentPolicyDrawer(rows) {
      if (rows.length === 0) return;

      const [selectedPolicy] = rows;
      this.selectedPolicyName = selectedPolicy?.name;
      this.initialManifest = selectedPolicy?.yaml;
      this.initialEnforcementStatus = selectedPolicy?.enabled;
    },
    deselectPolicy() {
      this.selectedPolicyName = null;

      const bTable = this.$refs.policiesTable.$children[0];
      bTable.clearSelected();
    },
  },
  emptyStateDescription: s__(
    `NetworkPolicies|Policies are a specification of how groups of pods are allowed to communicate with each other's network endpoints.`,
  ),
  autodevopsNoticeDescription: s__(
    `NetworkPolicies|If you are using Auto DevOps, your %{monospacedStart}auto-deploy-values.yaml%{monospacedEnd} file will not be updated if you change a policy in this section. Auto DevOps users should make changes by following the %{linkStart}Container Network Policy documentation%{linkEnd}.`,
  ),
};
</script>

<template>
  <div>
    <gl-alert
      v-if="hasAutoDevopsPolicy"
      data-testid="autodevopsAlert"
      variant="info"
      :dismissible="false"
      class="gl-mb-3"
    >
      <gl-sprintf :message="$options.autodevopsNoticeDescription">
        <template #monospaced="{ content }">
          <span class="gl-font-monospace">{{ content }}</span>
        </template>
        <template #link="{ content }">
          <gl-link :href="documentationFullPath">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>

    <div class="pt-3 px-3 bg-gray-light">
      <div class="row justify-content-between align-items-center">
        <environment-picker ref="environmentsPicker" :include-all="true" />
        <div class="col-sm-auto">
          <gl-button
            category="secondary"
            variant="info"
            :href="newPolicyPath"
            data-testid="new-policy"
            >{{ s__('NetworkPolicies|New policy') }}</gl-button
          >
        </div>
      </div>
    </div>

    <gl-table
      ref="policiesTable"
      :busy="isLoadingPolicies"
      :items="policies"
      :fields="fields"
      head-variant="white"
      stacked="md"
      thead-class="gl-text-gray-900 border-bottom"
      tbody-class="gl-text-gray-900"
      show-empty
      hover
      selectable
      select-mode="single"
      selected-variant="primary"
      @row-selected="presentPolicyDrawer"
    >
      <template #cell(status)="value">
        {{ value.item.enabled ? __('Enabled') : __('Disabled') }}
      </template>

      <template #cell(updatedAt)="value">
        {{ getTimeAgoString(value.item.updatedAt) }}
      </template>

      <template #empty>
        <slot name="empty-state">
          <gl-empty-state
            ref="tableEmptyState"
            :title="s__('NetworkPolicies|No policies detected')"
            :description="$options.emptyStateDescription"
            :primary-button-link="documentationFullPath"
            :primary-button-text="__('Learn more')"
          />
        </slot>
      </template>
    </gl-table>

    <policy-drawer
      :open="hasSelectedPolicy"
      :policy="selectedPolicy"
      :edit-policy-path="editPolicyPath"
      data-testid="policyDrawer"
      @close="deselectPolicy"
    />
  </div>
</template>
