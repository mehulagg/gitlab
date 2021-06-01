<script>
import { GlButton, GlDrawer } from '@gitlab/ui';
import { getContentWrapperHeight } from '../../utils';
import { CiliumNetworkPolicyKind, ScanExecutionPolicyKind } from '../policy_editor/constants';
import ContainerRuntimePolicy from '../policy_editor/container_runtime_policy.vue';
import ScanExecutionPolicy from '../policy_editor/scan_execution_policy.vue';

const policyComponent = {
  [CiliumNetworkPolicyKind]: ContainerRuntimePolicy,
  [ScanExecutionPolicyKind]: ScanExecutionPolicy,
};

export default {
  components: {
    GlButton,
    GlDrawer,
    NetworkPolicyEditor: () =>
      import(/* webpackChunkName: 'network_policy_editor' */ '../network_policy_editor.vue'),
    ContainerRuntimePolicy,
    ScanExecutionPolicy,
  },
  props: {
    policy: {
      type: Object,
      required: false,
      default: null,
    },
    editPolicyPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    policyKind() {
      if (this.policy?.manifest?.includes(CiliumNetworkPolicyKind)) {
        return CiliumNetworkPolicyKind;
      }
      if (this.policy?.manifest?.includes(ScanExecutionPolicyKind)) {
        return ScanExecutionPolicyKind;
      }
      return null;
    },
    policyComponent() {
      return policyComponent[this.policyKind] || null;
    },
  },
  methods: {
    getDrawerHeaderHeight() {
      return getContentWrapperHeight('.js-threat-monitoring-container-wrapper');
    },
  },
};
</script>

<template>
  <gl-drawer
    :z-index="252"
    :header-height="getDrawerHeaderHeight()"
    v-bind="$attrs"
    v-on="$listeners"
  >
    <template v-if="policy" #header>
      <div>
        <h3 class="gl-mb-5 gl-mt-0">{{ policy.name }}</h3>
        <div>
          <gl-button
            data-testid="edit-button"
            category="primary"
            variant="info"
            :href="editPolicyPath"
            >{{ s__('NetworkPolicies|Edit policy') }}</gl-button
          >
        </div>
      </div>
    </template>
    <div v-if="policy">
      <component :is="policyComponent" v-if="policyComponent" :value="policy.manifest" />
      <div v-else>
        <h5>{{ s__('NetworkPolicies|Policy definition') }}</h5>
        <p>
          {{ s__("NetworkPolicies|Define this policy's location, conditions and actions.") }}
        </p>
        <div class="gl-p-3 gl-bg-gray-50">
          <network-policy-editor
            :value="policy.manifest"
            data-testid="policyEditor"
            class="network-policy-editor"
          />
        </div>
      </div>
    </div>
  </gl-drawer>
</template>
