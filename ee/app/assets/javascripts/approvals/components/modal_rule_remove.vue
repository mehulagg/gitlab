<script>
import { GlSprintf } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { n__, s__, __ } from '~/locale';
import GlModalVuex from '~/vue_shared/components/gl_modal_vuex.vue';

const i18n = {
  cancelButtonText: __('Cancel'),
  primaryButtonText: __('Remove approvers'),
  modalTitle: __('Remove approvers?'),
  removeWarningText: s__(
    'ApprovalRuleRemove|You are about to remove the %{name} approver group which has %{nMembers}.',
  ),
};

export default {
  components: {
    GlModalVuex,
    GlSprintf,
  },
  props: {
    modalId: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState('deleteModal', {
      rule: 'data',
    }),
    membersText() {
      return n__(
        'ApprovalRuleRemove|%d member',
        'ApprovalRuleRemove|%d members',
        this.rule.approvers.length,
      );
    },
    revokeWarningText() {
      return n__(
        'ApprovalRuleRemove|Approvals from this member are not revoked.',
        'ApprovalRuleRemove|Approvals from these members are not revoked.',
        this.rule.approvers.length,
      );
    },
    modalText() {
      return `${i18n.removeWarningText} ${this.revokeWarningText}`;
    },
  },
  methods: {
    ...mapActions(['deleteRule']),
    submit() {
      this.deleteRule(this.rule.id);
    },
  },
  buttonActions: {
    primary: {
      text: i18n.primaryButtonText,
      attributes: [{ variant: 'danger' }],
    },
    cancel: {
      text: i18n.cancelButtonText,
    },
  },
  i18n,
};
</script>

<template>
  <gl-modal-vuex
    modal-module="deleteModal"
    :modal-id="modalId"
    :title="$options.i18n.modalTitle"
    :action-primary="$options.buttonActions.primary"
    :action-cancel="$options.buttonActions.cancel"
    @ok.prevent="submit"
  >
    <p v-if="rule">
      <gl-sprintf :message="modalText">
        <template #name>
          <strong>{{ rule.name }}</strong>
        </template>
        <template #nMembers>
          <strong>{{ membersText }}</strong>
        </template>
        <template #revokeWarning>
          {{ revokeWarningText }}
        </template>
      </gl-sprintf>
    </p>
  </gl-modal-vuex>
</template>
