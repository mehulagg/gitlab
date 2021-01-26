<script>
/* eslint-disable vue/no-v-html */
import { mapActions, mapState } from 'vuex';
import { escape } from 'lodash';
import { sprintf, n__, s__ } from '~/locale';
import GlModalVuex from '~/vue_shared/components/gl_modal_vuex.vue';

export default {
  components: {
    GlModalVuex,
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
    message() {
      if (!this.rule) {
        return '';
      }

      const nMembers = n__(
        'ApprovalRuleRemove|%d member',
        'ApprovalRuleRemove|%d members',
        this.rule.approvers.length,
      );
      const removeWarning = sprintf(
        s__(
          'ApprovalRuleRemove|You are about to remove the %{name} approver group which has %{nMembers}.',
        ),
        {
          name: `<strong>${escape(this.rule.name)}</strong>`,
          nMembers: `<strong>${nMembers}</strong>`,
        },
        false,
      );
      const revokeWarning = n__(
        'ApprovalRuleRemove|Approvals from this member are not revoked.',
        'ApprovalRuleRemove|Approvals from these members are not revoked.',
        this.rule.approvers.length,
      );

      return `${removeWarning} ${revokeWarning}`;
    },
  },
  methods: {
    ...mapActions(['deleteRule']),
    submit() {
      this.deleteRule(this.rule.id);
    },
  },
};
</script>

<template>
  <gl-modal-vuex
    modal-module="deleteModal"
    :modal-id="modalId"
    :title="__('Remove approvers?')"
    :ok-title="__('Remove approvers')"
    ok-variant="remove"
    :cancel-title="__('Cancel')"
    @ok.prevent="submit"
  >
    <p v-html="message"></p>
  </gl-modal-vuex>
</template>
