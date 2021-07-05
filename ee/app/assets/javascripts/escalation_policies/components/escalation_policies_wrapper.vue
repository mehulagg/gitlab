<script>
import { GlEmptyState, GlButton, GlModalDirective, GlLoadingIcon } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { s__ } from '~/locale';
import { addEscalationPolicyModalId } from '../constants';
import getEscalationPoliciesQuery from '../graphql/queries/get_escalation_policies.query.graphql';
import { parsePolicy } from '../utils';
import AddEscalationPolicyModal from './add_edit_escalation_policy_modal.vue';
import EscalationPolicy from './escalation_policy.vue';

export const i18n = {
  title: s__('EscalationPolicies|Escalation policies'),
  addPolicy: s__('EscalationPolicies|Add policy'),
  emptyState: {
    title: s__('EscalationPolicies|Create an escalation policy in GitLab'),
    description: s__(
      "EscalationPolicies|Set up escalation policies to define who is paged, and when, in the event the first users paged don't respond.",
    ),
    button: s__('EscalationPolicies|Add an escalation policy'),
  },
};

export default {
  i18n,
  addEscalationPolicyModalId,
  components: {
    GlEmptyState,
    GlButton,
    GlLoadingIcon,
    AddEscalationPolicyModal,
    EscalationPolicy,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  inject: ['projectPath', 'emptyEscalationPoliciesSvgPath'],
  data() {
    return {
      escalationPolicies: [],
    };
  },
  apollo: {
    escalationPolicies: {
      query: getEscalationPoliciesQuery,
      variables() {
        return {
          projectPath: this.projectPath,
        };
      },
      update({ project }) {
        return project?.incidentManagementEscalationPolicies?.nodes.map(parsePolicy) ?? [];
      },
      error(error) {
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.escalationPolicies.loading;
    },
    hasPolicies() {
      return this.escalationPolicies.length;
    },
  },
};
</script>

<template>
  <div>
    <gl-loading-icon v-if="isLoading" size="lg" class="gl-mt-3" />

    <template v-else-if="hasPolicies">
      <div class="gl-display-flex gl-justify-content-space-between gl-align-items-center">
        <h2>{{ $options.i18n.title }}</h2>
      </div>
      <escalation-policy
        v-for="(policy, index) in escalationPolicies"
        :key="policy.id"
        :policy="policy"
        :index="index"
      />
    </template>

    <gl-empty-state
      v-else
      :title="$options.i18n.emptyState.title"
      :description="$options.i18n.emptyState.description"
      :svg-path="emptyEscalationPoliciesSvgPath"
    >
      <template #actions>
        <gl-button v-gl-modal="$options.addEscalationPolicyModalId" variant="confirm">
          {{ $options.i18n.emptyState.button }}
        </gl-button>
      </template>
    </gl-empty-state>
    <add-escalation-policy-modal :modal-id="$options.addEscalationPolicyModalId" />
  </div>
</template>
