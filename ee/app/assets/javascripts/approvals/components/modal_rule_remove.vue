<script>
import { GlSprintf } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { n__, s__, __ } from '~/locale';
import GlModalVuex from '~/vue_shared/components/gl_modal_vuex.vue';
import { RULE_TYPE_EXTERNAL_APPROVAL } from '../constants';

const i18n = {
  cancelButtonText: __('Cancel'),
  regularRule: {
    primaryButtonText: __('Remove approvers'),
    modalTitle: __('Remove approvers?'),
    removeWarningText: s__(
      'ApprovalRuleRemove|You are about to remove the %{name} approver group which has %{nMembers}.',
    ),
  },
  externalRule: {
    primaryButtonText: s__('ApprovalRuleRemove|Remove approval gate'),
    modalTitle: s__('ApprovalRuleRemove|Remove approval gate?'),
    removeWarningText: s__(
      'ApprovalRuleRemove|You are about to remove the %{name} approval gate. Approval from this service is not revoked.',
    ),
  },
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
    isExternalApprovalRule() {
      return this.rule?.ruleType === RULE_TYPE_EXTERNAL_APPROVAL;
    },
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
    modalTitle() {
      return this.isExternalApprovalRule
        ? i18n.externalRule.modalTitle
        : i18n.regularRule.modalTitle;
    },
    modalText() {
      return this.isExternalApprovalRule
        ? i18n.externalRule.removeWarningText
        : `${i18n.regularRule.removeWarningText} ${this.revokeWarningText}`;
    },
    primaryButtonProps() {
      const text = this.isExternalApprovalRule
        ? i18n.externalRule.primaryButtonText
        : i18n.regularRule.primaryButtonText;
      return {
        text,
        attributes: [{ variant: 'danger' }],
      };
    },
  },
  methods: {
    ...mapActions(['deleteRule', 'deleteExternalApprovalRule']),
    submit() {
      if (this.rule.externalUrl) {
        this.deleteExternalApprovalRule(this.rule.id);
      } else {
        this.deleteRule(this.rule.id);
      }
    },
  },
  cancelButtonProps: {
    text: i18n.cancelButtonText,
  },
  i18n,
};
</script>

<template>
  <gl-modal-vuex
    modal-module="deleteModal"
    :modal-id="modalId"
    :title="modalTitle"
    :action-primary="primaryButtonProps"
    :action-cancel="$options.cancelButtonProps"
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
      </gl-sprintf>
    </p>
  </gl-modal-vuex>
</template>
