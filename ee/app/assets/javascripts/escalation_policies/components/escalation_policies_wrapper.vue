<script>
import { GlEmptyState, GlButton, GlModalDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import AddEscalationPolicyModal from './add_edit_escalation_policy_modal.vue';

export const addEscalationPolicyModalId = 'addEscalationPolicyModal';

export const i18n = {
  emptyState: {
    title: s__('EscalationPolicies|Create an escalation policy in GitLab'),
    description: s__(
      "EscalationPolicies|Set up escalation policies to define who is paged, and when, in the event the first users paged don't respond.",
    ),
    button: s__('EscalationPolicies|Add an escalation policy'),
  },
  successNotification: {
    title: s__('EscalationPolicies|Done'),
    description: s__('EscalationPolicies|Your escalation policy has been successfully created.'),
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
  data() {
    return {
      showSuccessNotification: false,
    };
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="showSuccessNotification"
      variant="tip"
      :title="$options.i18n.successNotification.title"
      class="gl-my-3"
      @dismiss="showSuccessNotification = false"
    >
      <gl-sprintf :message="alertMessage">
        <template #link="{ content }">
          <gl-link :href="$options.escalationPolicyUrl" target="_blank">
            {{ content }}
          </gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>
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
    <add-escalation-policy-modal
      :modal-id="$options.addEscalationPolicyModalId"
      @esclationPolicyCreated="showSuccessNotification = true"
    />
  </div>
</template>
