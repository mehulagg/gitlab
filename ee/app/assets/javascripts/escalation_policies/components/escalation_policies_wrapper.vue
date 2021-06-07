<script>
import { GlEmptyState, GlButton, GlModalDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import { addEscalationPolicyModalId } from '../constants';
import AddEscalationPolicyModal from './add_edit_escalation_policy_modal.vue';

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
  },
  directives: {
    GlModal: GlModalDirective,
  },
  inject: ['emptyEscalationPoliciesSvgPath'],
};
</script>

<template>
  <div>
    <gl-empty-state
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
    <add-escalation-policy-modal />
  </div>
</template>
