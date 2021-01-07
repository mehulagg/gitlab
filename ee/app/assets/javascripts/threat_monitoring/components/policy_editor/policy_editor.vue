<script>
import { mapState, mapActions } from 'vuex';
import {
  GlFormGroup,
  GlFormSelect,
  GlFormInput,
  GlFormTextarea,
  GlToggle,
  GlSegmentedControl,
  GlButton,
  GlAlert,
  GlModal,
  GlModalDirective,
} from '@gitlab/ui';
import { s__, __, sprintf } from '~/locale';
import { redirectTo } from '~/lib/utils/url_utility';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import EnvironmentPicker from '../environment_picker.vue';
import NetworkPolicyEditor from '../network_policy_editor.vue';
import PolicyRuleBuilder from './policy_rule_builder.vue';
import PolicyPreview from './policy_preview.vue';
import PolicyActionPicker from './policy_action_picker.vue';
import PolicyAlertPicker from './policy_alert_picker.vue';
import DimDisableContainer from './dim_disable_container.vue';
import {
  EditorModeRule,
  EditorModeYAML,
  EndpointMatchModeAny,
  RuleTypeEndpoint,
} from './constants';
import toYaml from './lib/to_yaml';
import fromYaml from './lib/from_yaml';
import { buildRule } from './lib/rules';
import humanizeNetworkPolicy from './lib/humanize';

export default {
  components: {
    GlFormGroup,
    GlFormSelect,
    GlFormInput,
    GlFormTextarea,
    GlToggle,
    GlSegmentedControl,
    GlButton,
    GlAlert,
    GlModal,
    EnvironmentPicker,
    NetworkPolicyEditor,
    PolicyRuleBuilder,
    PolicyPreview,
    PolicyActionPicker,
    PolicyAlertPicker,
    DimDisableContainer,
  },
  directives: { GlModal: GlModalDirective },
  mixins: [glFeatureFlagsMixin()],
  props: {
    threatMonitoringPath: {
      type: String,
      required: true,
    },
    existingPolicy: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    const policy = this.existingPolicy
      ? fromYaml(this.existingPolicy.manifest)
      : {
          name: '',
          description: '',
          isEnabled: false,
          endpointMatchMode: EndpointMatchModeAny,
          endpointLabels: '',
          rules: [],
          annotations: '',
        };

    return {
      editorMode: EditorModeRule,
      yamlEditorValue: '',
      yamlEditorError: null,
      policy,
    };
  },
  computed: {
    humanizedPolicy() {
      return humanizeNetworkPolicy(this.policy);
    },
    policyAlert() {
      return Boolean(this.policy.annotations);
    },
    policyYaml() {
      return toYaml(this.policy);
    },
    ...mapState('threatMonitoring', ['currentEnvironmentId']),
    ...mapState('networkPolicies', [
      'isUpdatingPolicy',
      'isRemovingPolicy',
      'errorUpdatingPolicy',
      'errorRemovingPolicy',
    ]),
    shouldShowRuleEditor() {
      return this.editorMode === EditorModeRule;
    },
    shouldShowYamlEditor() {
      return this.editorMode === EditorModeYAML;
    },
    hasParsingError() {
      return Boolean(this.yamlEditorError);
    },
    isEditing() {
      return Boolean(this.existingPolicy);
    },
    saveButtonText() {
      return this.isEditing
        ? s__('NetworkPolicies|Save changes')
        : s__('NetworkPolicies|Create policy');
    },
    showAlertsPicker() {
      return this.glFeatures.threatMonitoringAlerts;
    },
    deleteModalTitle() {
      return sprintf(s__('NetworkPolicies|Delete policy: %{policy}'), { policy: this.policy.name });
    },
  },
  created() {
    this.fetchEnvironments();
  },
  methods: {
    ...mapActions('threatMonitoring', ['fetchEnvironments']),
    ...mapActions('networkPolicies', ['createPolicy', 'updatePolicy', 'deletePolicy']),
    addRule() {
      this.policy.rules.push(buildRule(RuleTypeEndpoint));
    },
    handleAlertUpdate(includeAlert) {
      this.policy.annotations = includeAlert ? { 'app.gitlab.com/alert': 'true' } : '';
    },
    updateEndpointMatchMode(mode) {
      this.policy.endpointMatchMode = mode;
    },
    updateEndpointLabels(labels) {
      this.policy.endpointLabels = labels;
    },
    updateRuleType(ruleIdx, ruleType) {
      const rule = this.policy.rules[ruleIdx];
      this.policy.rules.splice(ruleIdx, 1, buildRule(ruleType, rule));
    },
    removeRule(ruleIdx) {
      this.policy.rules.splice(ruleIdx, 1);
    },
    loadYaml(manifest) {
      this.yamlEditorValue = manifest;
      this.yamlEditorError = null;

      try {
        Object.assign(this.policy, fromYaml(manifest));
      } catch (error) {
        this.yamlEditorError = error;
      }
    },
    changeEditorMode(mode) {
      if (mode === EditorModeYAML && !this.hasParsingError) {
        this.yamlEditorValue = toYaml(this.policy);
      }

      this.editorMode = mode;
    },
    savePolicy() {
      const saveFn = this.isEditing ? this.updatePolicy : this.createPolicy;
      const policy = { manifest: toYaml(this.policy) };
      if (this.isEditing) {
        policy.name = this.existingPolicy.name;
      }

      return saveFn({ environmentId: this.currentEnvironmentId, policy }).then(() => {
        if (!this.errorUpdatingPolicy) redirectTo(this.threatMonitoringPath);
      });
    },
    removePolicy() {
      const policy = { name: this.existingPolicy.name, manifest: toYaml(this.policy) };

      return this.deletePolicy({ environmentId: this.currentEnvironmentId, policy }).then(() => {
        if (!this.errorRemovingPolicy) redirectTo(this.threatMonitoringPath);
      });
    },
  },
  policyTypes: [{ value: 'networkPolicy', text: s__('NetworkPolicies|Network Policy') }],
  editorModes: [
    { value: EditorModeRule, text: s__('NetworkPolicies|Rule mode') },
    { value: EditorModeYAML, text: s__('NetworkPolicies|.yaml mode') },
  ],
  parsingErrorMessage: s__(
    'NetworkPolicies|Rule mode is unavailable for this policy. In some cases, we cannot parse the YAML file back into the rules editor.',
  ),
  deleteModal: {
    id: 'delete-modal',
    secondary: {
      text: s__('NetworkPolicies|Delete policy'),
      attributes: { variant: 'danger' },
    },
    cancel: {
      text: __('Cancel'),
    },
  },
};
</script>

<template>
  <section>
    <header class="my-3">
      <h2 class="h3 mb-1">
        {{ s__('NetworkPolicies|Policy description') }}
      </h2>
    </header>

    <div class="row">
      <div class="col-sm-6 col-md-4 col-lg-3 col-xl-2">
        <gl-form-group :label="s__('NetworkPolicies|Policy type')" label-for="policyType">
          <gl-form-select
            id="policyType"
            value="networkPolicy"
            :options="$options.policyTypes"
            disabled
          />
        </gl-form-group>
      </div>
      <div class="col-sm-6 col-md-6 col-lg-5 col-xl-4">
        <gl-form-group :label="s__('NetworkPolicies|Name')" label-for="policyName">
          <gl-form-input id="policyName" v-model="policy.name" />
        </gl-form-group>
      </div>
    </div>
    <div class="row">
      <div class="col-sm-12 col-md-10 col-lg-8 col-xl-6">
        <gl-form-group :label="s__('NetworkPolicies|Description')" label-for="policyDescription">
          <gl-form-textarea id="policyDescription" v-model="policy.description" />
        </gl-form-group>
      </div>
    </div>
    <div class="row">
      <environment-picker />
    </div>
    <div class="row">
      <div class="col-md-auto">
        <gl-form-group :label="s__('NetworkPolicies|Policy status')" label-for="policyStatus">
          <gl-toggle id="policyStatus" v-model="policy.isEnabled" />
        </gl-form-group>
      </div>
    </div>
    <div class="row">
      <div class="col-md-auto">
        <gl-form-group :label="s__('NetworkPolicies|Editor mode')" label-for="editorMode">
          <gl-segmented-control
            data-testid="editor-mode"
            :options="$options.editorModes"
            :checked="editorMode"
            @input="changeEditorMode"
          />
        </gl-form-group>
      </div>
    </div>
    <hr />
    <div v-if="shouldShowRuleEditor" class="row" data-testid="rule-editor">
      <div class="col-sm-12 col-md-6 col-lg-7 col-xl-8">
        <gl-alert
          v-if="hasParsingError"
          class="gl-z-index-1"
          data-testid="parsing-alert"
          :dismissible="false"
          >{{ $options.parsingErrorMessage }}</gl-alert
        >

        <dim-disable-container data-testid="rule-builder-container" :disabled="hasParsingError">
          <template #title>
            <h4>{{ s__('NetworkPolicies|Rules') }}</h4>
          </template>

          <template #disabled>
            <div
              class="gl-bg-gray-10 gl-border-solid gl-border-1 gl-border-gray-100 gl-rounded-base gl-p-6"
            ></div>
          </template>

          <policy-rule-builder
            v-for="(rule, idx) in policy.rules"
            :key="idx"
            class="gl-mb-4"
            :rule="rule"
            :endpoint-match-mode="policy.endpointMatchMode"
            :endpoint-labels="policy.endpointLabels"
            :endpoint-selector-disabled="idx > 0"
            @rule-type-change="updateRuleType(idx, $event)"
            @endpoint-match-mode-change="updateEndpointMatchMode"
            @endpoint-labels-change="updateEndpointLabels"
            @remove="removeRule(idx)"
          />

          <div
            class="gl-p-3 gl-rounded-base gl-border-1 gl-border-solid gl-border-gray-100 gl-mb-5"
          >
            <gl-button variant="link" category="primary" data-testid="add-rule" @click="addRule">{{
              s__('Network Policy|New rule')
            }}</gl-button>
          </div>
        </dim-disable-container>

        <dim-disable-container data-testid="policy-action-container" :disabled="hasParsingError">
          <template #title>
            <h4>{{ s__('NetworkPolicies|Actions') }}</h4>
            <p>
              {{ s__('NetworkPolicies|Traffic that does not match any rule will be blocked.') }}
            </p>
          </template>

          <template #disabled>
            <div
              class="gl-bg-gray-10 gl-border-solid gl-border-1 gl-border-gray-100 gl-rounded-base gl-p-6"
            ></div>
          </template>

          <policy-action-picker />
          <policy-alert-picker
            v-if="showAlertsPicker"
            :policy-alert="policyAlert"
            @update-alert="handleAlertUpdate"
          />
        </dim-disable-container>
      </div>
      <div class="col-sm-12 col-md-6 col-lg-5 col-xl-4">
        <dim-disable-container data-testid="policy-preview-container" :disabled="hasParsingError">
          <template #title>
            <h5>{{ s__('NetworkPolicies|Policy preview') }}</h5>
          </template>

          <template #disabled>
            <policy-preview
              :policy-yaml="s__('NetworkPolicies|Unable to parse policy')"
              policy-description=""
            />
          </template>

          <policy-preview :policy-yaml="policyYaml" :policy-description="humanizedPolicy" />
        </dim-disable-container>
      </div>
    </div>
    <div v-if="shouldShowYamlEditor" class="row" data-testid="yaml-editor">
      <div class="col-sm-12 col-md-12 col-lg-10 col-xl-8">
        <div class="gl-rounded-base gl-border-1 gl-border-solid gl-border-gray-100">
          <h5
            class="gl-m-0 gl-p-4 gl-bg-gray-10 gl-border-1 gl-border-b-solid gl-border-b-gray-100"
          >
            {{ s__('NetworkPolicies|YAML editor') }}
          </h5>
          <div class="gl-p-4">
            <network-policy-editor
              :value="yamlEditorValue"
              :height="400"
              :read-only="false"
              @input="loadYaml"
            />
          </div>
        </div>
      </div>
    </div>
    <hr />
    <div class="row">
      <div class="col-md-auto">
        <gl-button
          type="submit"
          category="primary"
          variant="success"
          data-testid="save-policy"
          :loading="isUpdatingPolicy"
          @click="savePolicy"
          >{{ saveButtonText }}</gl-button
        >
        <gl-button
          v-if="isEditing"
          v-gl-modal="'delete-modal'"
          category="secondary"
          variant="danger"
          data-testid="delete-policy"
          :loading="isRemovingPolicy"
          >{{ s__('NetworkPolicies|Delete policy') }}</gl-button
        >
        <gl-button category="secondary" variant="default" :href="threatMonitoringPath">{{
          __('Cancel')
        }}</gl-button>
      </div>
    </div>
    <gl-modal
      modal-id="delete-modal"
      :title="deleteModalTitle"
      :action-secondary="$options.deleteModal.secondary"
      :action-cancel="$options.deleteModal.cancel"
      @secondary="removePolicy"
    >
      {{
        s__(
          'NetworkPolicies|Are you sure you want to delete this policy? This action cannot be undone.',
        )
      }}
    </gl-modal>
  </section>
</template>
