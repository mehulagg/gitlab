<script>
import { GlModalDirective, GlTooltipDirective, GlButton, GlButtonGroup, GlCard } from '@gitlab/ui';
import { s__ } from '~/locale';
import { editEscalationPolicyModalId } from '../constants';
import EditEscalationPolicyModal from './add_edit_escalation_policy_modal.vue';

export const i18n = {
  editPolicy: s__('EscalationPolicies|Edit escalation policy'),
  deletePolicy: s__('EscalationPolicies|Delete escalation policy'),
};

export default {
  i18n,
  components: {
    GlButton,
    GlButtonGroup,
    GlCard,
    EditEscalationPolicyModal,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    policy: {
      type: Object,
      required: true,
    },
  },
  computed: {
    editPolicyModalId() {
      return `${editEscalationPolicyModalId}-${this.policy.id}`;
    },
  },
};
</script>

<template>
  <div>
    <gl-card class="gl-mt-5" header-class="gl-py-3">
      <template #header>
        <div
          class="gl-display-flex gl-justify-content-space-between gl-align-items-center gl-m-0"
          data-testid="scheduleHeader"
        >
          <span class="gl-font-weight-bold gl-font-lg">{{ policy.name }}</span>
          <gl-button-group>
            <gl-button
              v-gl-modal="editPolicyModalId"
              v-gl-tooltip
              :title="$options.i18n.editPolicy"
              icon="pencil"
              :aria-label="$options.i18n.editPolicy"
            />
            <gl-button
              v-gl-tooltip
              :title="$options.i18n.deletePolicy"
              icon="remove"
              :aria-label="$options.i18n.deletePolicy"
              disabled=""
            />
          </gl-button-group>
        </div>
      </template>
    </gl-card>

    <edit-escalation-policy-modal
      :escalation-policy="policy"
      :modal-id="editPolicyModalId"
      is-edit-mode
    />
  </div>
</template>
