<script>
import { GlButton, GlDrawer } from '@gitlab/ui';
import { getContentWrapperHeight } from '../utils';
import { CiliumNetworkPolicyKind } from './policy_editor/constants';
import PolicyDrawer from './policy_editor/policy_drawer.vue';

export default {
  components: {
    GlButton,
    GlDrawer,
    NetworkPolicyEditor: () =>
      import(/* webpackChunkName: 'network_policy_editor' */ './network_policy_editor.vue'),
    PolicyDrawer,
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
    isCiliumPolicy() {
      return this.policy ? this.policy.manifest.includes(CiliumNetworkPolicyKind) : false;
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
      <policy-drawer v-if="isCiliumPolicy" :value="policy.manifest" />

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
