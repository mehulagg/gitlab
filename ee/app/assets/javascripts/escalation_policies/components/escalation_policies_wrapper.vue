<script>
import { GlEmptyState, GlButton, GlModalDirective } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { s__ } from '~/locale';
import { addEscalationPolicyModalId } from '../constants';
import getEscalationPoliciesQuery from '../graphql/queries/get_escalatin_policies.query.graphql';
import AddEscalationPolicyModal from './add_edit_escalation_policy_modal.vue';
import EscalationPolicy from './escalation_policy.vue';

export const i18n = {
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
      update(data) {
        const nodes = data.project?.incidentManagementEscalationPolicies?.nodes ?? [];

        return nodes;
      },
      error(error) {
        Sentry.captureException(error);
      },
    },
  },
};
</script>

<template>
  <div>
    <template v-if="escalationPolicies.length">
      <escalation-policy v-for="policy in escalationPolicies" :key="policy.id" :policy="policy" />
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
