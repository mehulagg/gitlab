<script>
import { GlTable, GlEmptyState, GlButton, GlAlert, GlSprintf, GlLink } from '@gitlab/ui';
import { mapState, mapActions, mapGetters } from 'vuex';
import { getTimeago } from '~/lib/utils/datetime_utility';
import { setUrlFragment, mergeUrlParams } from '~/lib/utils/url_utility';
import { s__ } from '~/locale';
import EnvironmentPicker from './environment_picker.vue';
import NetworkPolicyDrawer from './policy_drawer/network_policy_drawer.vue';

export default {
  components: {
    GlTable,
    GlEmptyState,
    GlButton,
    GlAlert,
    GlSprintf,
    GlLink,
    EnvironmentPicker,
    NetworkPolicyDrawer,
  },
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
  data() {
    return { selectedPolicyName: null, initialManifest: null, initialEnforcementStatus: null };
  },
  computed: {
    ...mapState('networkPolicies', ['policies', 'isLoadingPolicies']),
    ...mapState('threatMonitoring', ['currentEnvironmentId', 'allEnvironments']),
    ...mapGetters('networkPolicies', ['policiesWithDefaults']),
    documentationFullPath() {
      return setUrlFragment(this.documentationPath, 'container-network-policy');
    },
    hasSelectedPolicy() {
      return Boolean(this.selectedPolicyName);
    },
    selectedPolicy() {
      if (!this.hasSelectedPolicy) return null;

      return this.policiesWithDefaults.find((policy) => policy.name === this.selectedPolicyName);
    },
    hasAutoDevopsPolicy() {
      return this.policiesWithDefaults.some((policy) => policy.isAutodevops);
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
        thClass: 'font-weight-bold',
      };
      const fields = [
        {
          key: 'name',
          label: s__('NetworkPolicies|Name'),
          thClass: 'w-50 font-weight-bold',
        },
        {
          key: 'status',
          label: s__('NetworkPolicies|Status'),
          thClass: 'font-weight-bold',
        },
        {
          key: 'creationTimestamp',
          label: s__('NetworkPolicies|Last modified'),
          thClass: 'font-weight-bold',
        },
      ];
      // Adds column 'namespace' only while 'all environments' option is selected
      if (this.allEnvironments) fields.splice(1, 0, namespace);

      return fields;
    },
  },
  watch: {
    currentEnvironmentId(envId) {
      this.fetchPolicies(envId);
    },
  },
  created() {
    this.fetchPolicies(this.currentEnvironmentId);
  },
  methods: {
    ...mapActions('networkPolicies', ['fetchPolicies', 'createPolicy', 'updatePolicy']),
    getTimeAgoString(creationTimestamp) {
      if (!creationTimestamp) return '';
      return getTimeago().format(creationTimestamp);
    },
    presentPolicyDrawer(rows) {
      if (rows.length === 0) return;

      const [selectedPolicy] = rows;
      this.selectedPolicyName = selectedPolicy?.name;
      this.initialManifest = selectedPolicy?.manifest;
      this.initialEnforcementStatus = selectedPolicy?.isEnabled;
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
      :items="policiesWithDefaults"
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
        {{ value.item.isEnabled ? __('Enabled') : __('Disabled') }}
      </template>

      <template #cell(creationTimestamp)="value">
        {{ getTimeAgoString(value.item.creationTimestamp) }}
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

    <network-policy-drawer
      :open="hasSelectedPolicy"
      :policy="selectedPolicy"
      :edit-policy-path="editPolicyPath"
      data-testid="policyDrawer"
      @close="deselectPolicy"
    />
  </div>
</template>
