<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import {
  GlTable,
  GlEmptyState,
  GlDrawer,
  GlButton,
  GlAlert,
  GlSprintf,
  GlLink,
  GlToggle,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import { getTimeago } from '~/lib/utils/datetime_utility';
import { setUrlFragment, mergeUrlParams } from '~/lib/utils/url_utility';
import EnvironmentPicker from './environment_picker.vue';
import NetworkPolicyEditor from './network_policy_editor.vue';
import PolicyDrawer from './policy_editor/policy_drawer.vue';
import { CiliumNetworkPolicyKind } from './policy_editor/constants';

export default {
  components: {
    GlTable,
    GlEmptyState,
    GlDrawer,
    GlButton,
    GlAlert,
    GlSprintf,
    GlLink,
    GlToggle,
    EnvironmentPicker,
    NetworkPolicyEditor,
    PolicyDrawer,
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
    ...mapState('networkPolicies', ['policies', 'isLoadingPolicies', 'isUpdatingPolicy']),
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
    hasPolicyChanges() {
      if (!this.hasSelectedPolicy) return false;

      return (
        this.selectedPolicy.manifest !== this.initialManifest ||
        this.selectedPolicy.isEnabled !== this.initialEnforcementStatus
      );
    },
    hasAutoDevopsPolicy() {
      return this.policiesWithDefaults.some((policy) => policy.isAutodevops);
    },
    hasCiliumSelectedPolicy() {
      return this.hasSelectedPolicy
        ? this.selectedPolicy.manifest.includes(CiliumNetworkPolicyKind)
        : false;
    },
    shouldShowCiliumDrawer() {
      return this.hasCiliumSelectedPolicy;
    },
    shouldShowEditButton() {
      return this.hasCiliumSelectedPolicy && Boolean(this.selectedPolicy.creationTimestamp);
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
    savePolicy() {
      const promise = this.selectedPolicy.creationTimestamp ? this.updatePolicy : this.createPolicy;
      return promise({
        environmentId: this.currentEnvironmentId,
        policy: this.selectedPolicy,
      })
        .then(() => {
          this.initialManifest = this.selectedPolicy.manifest;
          this.initialEnforcementStatus = this.selectedPolicy.isEnabled;
        })
        .catch(() => {
          this.selectedPolicy.manifest = this.initialManifest;
          this.selectedPolicy.isEnabled = this.initialEnforcementStatus;
        });
    },
  },
  emptyStateDescription: s__(
    `NetworkPolicies|Policies are a specification of how groups of pods are allowed to communicate with each other's network endpoints.`,
  ),
  autodevopsNoticeDescription: s__(
    `NetworkPolicies|If you are using Auto DevOps, your %{monospacedStart}auto-deploy-values.yaml%{monospacedEnd} file will not be updated if you change a policy in this section. Auto DevOps users should make changes by following the %{linkStart}Container Network Policy documentation%{linkEnd}.`,
  ),
  headerHeight: process.env.NODE_ENV === 'development' ? '75px' : '40px',
};
</script>

<template>
  <div>
    <div class="mb-2">
      <gl-alert
        v-if="hasAutoDevopsPolicy"
        data-testid="autodevopsAlert"
        variant="info"
        :dismissible="false"
      >
        <gl-sprintf :message="$options.autodevopsNoticeDescription">
          <template #monospaced="{ content }">
            <span class="monospace">{{ content }}</span>
          </template>
          <template #link="{ content }">
            <gl-link :href="documentationFullPath">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </gl-alert>
    </div>

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

    <gl-drawer
      ref="editorDrawer"
      :z-index="252"
      :open="hasSelectedPolicy"
      :header-height="$options.headerHeight"
      @close="deselectPolicy"
    >
      <template #header>
        <div>
          <h3 class="gl-mb-3">{{ selectedPolicy.name }}</h3>
          <div>
            <gl-button ref="cancelButton" @click="deselectPolicy">{{ __('Cancel') }}</gl-button>
            <gl-button
              v-if="shouldShowEditButton"
              data-testid="edit-button"
              category="primary"
              variant="info"
              :href="editPolicyPath"
              >{{ s__('NetworkPolicies|Edit policy') }}</gl-button
            >
            <gl-button
              ref="applyButton"
              category="primary"
              variant="success"
              :loading="isUpdatingPolicy"
              :disabled="!hasPolicyChanges"
              @click="savePolicy"
              >{{ __('Apply changes') }}</gl-button
            >
          </div>
        </div>
      </template>
      <template>
        <div v-if="hasSelectedPolicy">
          <policy-drawer v-if="shouldShowCiliumDrawer" v-model="selectedPolicy.manifest" />

          <div v-else>
            <h5>{{ s__('NetworkPolicies|Policy definition') }}</h5>
            <p>
              {{ s__("NetworkPolicies|Define this policy's location, conditions and actions.") }}
            </p>
            <div class="gl-p-3 gl-bg-gray-50">
              <network-policy-editor
                ref="policyEditor"
                v-model="selectedPolicy.manifest"
                class="network-policy-editor"
              />
            </div>
          </div>

          <h5 class="gl-mt-6">{{ s__('NetworkPolicies|Enforcement status') }}</h5>
          <p>{{ s__('NetworkPolicies|Choose whether to enforce this policy.') }}</p>
          <gl-toggle v-model="selectedPolicy.isEnabled" data-testid="policyToggle" />
        </div>
      </template>
    </gl-drawer>
  </div>
</template>
