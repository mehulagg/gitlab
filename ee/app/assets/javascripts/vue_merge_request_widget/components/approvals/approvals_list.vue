<script>
import _ from 'lodash-es';
import { sprintf, __ } from '~/locale';
import UserAvatarList from '~/vue_shared/components/user_avatar/user_avatar_list.vue';
import { RULE_TYPE_CODE_OWNER } from 'ee/approvals/constants';
import ApprovedIcon from './approved_icon.vue';

export default {
  components: {
    UserAvatarList,
    ApprovedIcon,
  },
  props: {
    approvalRules: {
      type: Array,
      required: true,
    },
  },
  computed: {
    sections() {
      return [
        {
          id: _.uniqueId(),
          title: '',
          rules: this.approvalRules.filter(rule => rule.rule_type !== RULE_TYPE_CODE_OWNER),
        },
        {
          id: _.uniqueId(),
          title: __('Code Owners'),
          rules: this.approvalRules
            .filter(rule => rule.rule_type === RULE_TYPE_CODE_OWNER)
            .map(rule => ({ ...rule, nameClass: 'monospace' })),
        },
      ].filter(x => x.rules.length);
    },
  },
  methods: {
    pendingApprovalsText(rule) {
      if (!rule.approvals_required) {
        return __('Optional');
      }

      return sprintf(__('%{count} of %{total}'), {
        count: rule.approved_by.length,
        total: rule.approvals_required,
      });
    },
    summaryText(rule) {
      return rule.approvals_required === 0
        ? this.summaryOptionalText(rule)
        : this.summaryRequiredText(rule);
    },
    summaryRequiredText(rule) {
      return sprintf(__('%{count} of %{required} approvals from %{name}'), {
        count: rule.approved_by.length,
        required: rule.approvals_required,
        name: rule.name,
      });
    },
    summaryOptionalText(rule) {
      return sprintf(__('%{count} approvals from %{name}'), {
        count: rule.approved_by.length,
        name: rule.name,
      });
    },
  },
};
</script>

<template>
  <table class="table m-0">
    <thead class="thead-white text-nowrap">
      <tr class="d-none d-sm-table-row">
        <th class="w-0"></th>
        <th>{{ s__('MRApprovals|Approvers') }}</th>
        <th class="w-50"></th>
        <th>{{ s__('MRApprovals|Pending approvals') }}</th>
        <th>{{ s__('MRApprovals|Approved by') }}</th>
      </tr>
    </thead>
    <tbody v-for="{ id, title, rules } in sections" :key="id" class="border-top-0">
      <tr v-if="title" class="js-section-title">
        <td class="w-0"></td>
        <td colspan="99">
          <strong>{{ title }}</strong>
        </td>
      </tr>
      <tr v-for="rule in rules" :key="rule.id">
        <td class="w-0"><approved-icon :is-approved="rule.approved" /></td>
        <td :colspan="rule.fallback ? 2 : 1">
          <div class="d-none d-sm-block js-name" :class="rule.nameClass">{{ rule.name }}</div>
          <div class="d-flex d-sm-none flex-column js-summary">
            <span>{{ summaryText(rule) }}</span>
            <user-avatar-list
              v-if="!rule.fallback"
              class="mt-2"
              :items="rule.approvers"
              :img-size="24"
            />
            <div v-if="rule.approved_by.length" class="mt-2">
              <span>{{ s__('MRApprovals|Approved by') }}</span>
              <user-avatar-list
                class="d-inline-block align-middle"
                :items="rule.approved_by"
                :img-size="24"
              />
            </div>
          </div>
        </td>
        <td v-if="!rule.fallback" class="d-none d-sm-table-cell js-approvers">
          <div><user-avatar-list :items="rule.approvers" :img-size="24" /></div>
        </td>
        <td class="w-0 d-none d-sm-table-cell text-nowrap js-pending">
          {{ pendingApprovalsText(rule) }}
        </td>
        <td class="d-none d-sm-table-cell js-approved-by">
          <user-avatar-list :items="rule.approved_by" :img-size="24" />
        </td>
      </tr>
    </tbody>
  </table>
</template>
