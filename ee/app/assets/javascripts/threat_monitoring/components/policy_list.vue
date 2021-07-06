<script>
import {
  GlTable,
  GlEmptyState,
  GlButton,
  GlAlert,
  GlSprintf,
  GlLink,
  GlIcon,
  GlTooltipDirective,
} from '@gitlab/ui';
import { mapState, mapGetters } from 'vuex';
import { PREDEFINED_NETWORK_POLICIES } from 'ee/threat_monitoring/constants';
import createFlash from '~/flash';
import { getTimeago } from '~/lib/utils/datetime_utility';
import { setUrlFragment, mergeUrlParams } from '~/lib/utils/url_utility';
import { __, s__ } from '~/locale';
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

const getPoliciesWithType = (policies, policyType) =>
  policies.map((policy) => ({
    ...policy,
    policyType,
  }));

export default {
  components: {
    GlTable,
    GlEmptyState,
    GlButton,
    GlAlert,
    GlSprintf,
    GlLink,
    GlIcon,
    EnvironmentPicker,
    PolicyDrawer,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
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
      selectedPolicy: null,
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
      return [
        ...getPoliciesWithType(this.networkPolicies, s__('SecurityPolicies|Network')),
        ...getPoliciesWithType(this.scanExecutionPolicies, s__('SecurityPolicies|Scan execution')),
      ];
    },
    isLoadingPolicies() {
      return (
        this.isLoadingEnvironments ||
        this.$apollo.queries.networkPolicies.loading ||
        this.$apollo.queries.scanExecutionPolicies.loading
      );
    },
    hasSelectedPolicy() {
      return Boolean(this.selectedPolicy);
    },
    hasAutoDevopsPolicy() {
      return Boolean(this.networkPolicies?.some((policy) => policy.fromAutoDevops));
    },
    editPolicyPath() {
      return this.hasSelectedPolicy
        ? mergeUrlParams(
            !this.selectedPolicy.kind
              ? { environment_id: this.currentEnvironmentId }
              : { environment_id: this.currentEnvironmentId, kind: this.selectedPolicy.kind },
            this.newPolicyPath.replace('new', `${this.selectedPolicy.name}/edit`),
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
          key: 'status',
          label: '',
          thClass: 'gl-w-3',
          tdAttr: {
            'data-testid': 'policy-status-cell',
          },
        },
        {
          key: 'name',
          label: s__('NetworkPolicies|Name'),
          thClass: 'gl-w-half',
        },
        {
          key: 'policyType',
          label: s__('SecurityPolicies|Policy type'),
          sortable: true,
        },
        {
          key: 'updatedAt',
          label: s__('NetworkPolicies|Last modified'),
          sortable: true,
        },
      ];
      // Adds column 'namespace' only while 'all environments' option is selected
      if (this.allEnvironments) fields.splice(2, 0, namespace);

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
      this.selectedPolicy = selectedPolicy;
    },
    deselectPolicy() {
      this.selectedPolicy = null;

      const bTable = this.$refs.policiesTable.$children[0];
      bTable.clearSelected();
    },
  },
  i18n: {
    emptyStateDescription: s__(
      `NetworkPolicies|Policies are a specification of how groups of pods are allowed to communicate with each other's network endpoints.`,
    ),
    autodevopsNoticeDescription: s__(
      `NetworkPolicies|If you are using Auto DevOps, your %{monospacedStart}auto-deploy-values.yaml%{monospacedEnd} file will not be updated if you change a policy in this section. Auto DevOps users should make changes by following the %{linkStart}Container Network Policy documentation%{linkEnd}.`,
    ),
    statusEnabled: __('Enabled'),
    statusDisabled: __('Disabled'),
  },
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
      <gl-sprintf :message="$options.i18n.autodevopsNoticeDescription">
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
      sort-icon-left
      sort-by="updatedAt"
      sort-desc
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
        <gl-icon
          v-if="value.item.enabled"
          v-gl-tooltip="$options.i18n.statusEnabled"
          :aria-label="$options.i18n.statusEnabled"
          name="check-circle-filled"
          class="gl-text-green-700"
        />
        <span v-else class="gl-sr-only">{{ $options.i18n.statusDisabled }}</span>
      </template>

      <template #cell(updatedAt)="value">
        {{ getTimeAgoString(value.item.updatedAt) }}
      </template>

      <template #empty>
        <slot name="empty-state">
          <gl-empty-state
            ref="tableEmptyState"
            :title="s__('NetworkPolicies|No policies detected')"
            :description="$options.i18n.emptyStateDescription"
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
