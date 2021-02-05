<script>
import { uniqueId, orderBy } from 'lodash';
import ApprovalCheckRulePopover from 'ee/approvals/components/approval_check_rule_popover.vue';
import EmptyRuleName from 'ee/approvals/components/empty_rule_name.vue';
import { RULE_TYPE_CODE_OWNER, RULE_TYPE_ANY_APPROVER } from 'ee/approvals/constants';
import { sprintf, __, s__ } from '~/locale';
import UserAvatarList from '~/vue_shared/components/user_avatar/user_avatar_list.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ApprovedIcon from './approved_icon.vue';

export default {
  components: {
    UserAvatarList,
    ApprovedIcon,
    ApprovalCheckRulePopover,
    EmptyRuleName,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    approvalRules: {
      type: Array,
      required: true,
    },
    securityApprovalsHelpPagePath: {
      type: String,
      required: false,
      default: '',
    },
    eligibleApproversDocsPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    sections() {
      return [
        {
          id: uniqueId(),
          title: '',
          rules: this.approvalRules.filter((rule) => rule.rule_type !== RULE_TYPE_CODE_OWNER),
        },
        {
          id: uniqueId(),
          title: __('Code Owners'),
          rules: orderBy(
            this.approvalRules
              .filter((rule) => rule.rule_type === RULE_TYPE_CODE_OWNER)
              .map((rule) => ({ ...rule, nameClass: 'gl-font-monospace gl-word-break-all' })),
            [(o) => o.section === 'codeowners', 'name', 'section'],
            ['desc', 'asc', 'asc'],
          ),
        },
      ].filter((x) => x.rules.length);
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
    sectionNameLabel(rule) {
      return sprintf(s__('Approvals|Section: %section'), { section: rule.section });
    },
  },
  ruleTypeAnyApprover: RULE_TYPE_ANY_APPROVER,
};
</script>

<template>
  <table class="table m-0">
    <thead class="thead-white text-nowrap">
      <tr
        :class="glFeatures.approvalsCommentedBy ? 'd-md-table-row' : 'd-sm-table-row'"
        class="d-none"
      >
        <th class="w-0"></th>
        <th class="w-25">{{ s__('MRApprovals|Approvers') }}</th>
        <th class="w-50"></th>
        <th>{{ s__('MRApprovals|Approvals') }}</th>
        <th v-if="glFeatures.approvalsCommentedBy">{{ s__('MRApprovals|Commented by') }}</th>
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
        <td :colspan="rule.rule_type === $options.ruleTypeAnyApprover ? 2 : 1">
          <div
            :class="glFeatures.approvalsCommentedBy ? 'd-md-block' : 'd-sm-block'"
            class="d-none js-name"
          >
            <empty-rule-name
              v-if="rule.rule_type === $options.ruleTypeAnyApprover"
              :eligible-approvers-docs-path="eligibleApproversDocsPath"
            />
            <span v-else>
              <span
                v-if="rule.section && rule.section !== 'codeowners'"
                :aria-label="sectionNameLabel(rule)"
                class="text-muted small d-block"
                data-testid="rule-section"
              >
                {{ rule.section }}
              </span>
              <span :class="rule.nameClass">{{ rule.name }}</span>
            </span>
            <approval-check-rule-popover
              :rule="rule"
              :security-approvals-help-page-path="securityApprovalsHelpPagePath"
            />
          </div>
          <div
            :class="glFeatures.approvalsCommentedBy ? 'd-md-none' : 'd-sm-none'"
            class="d-flex flex-column js-summary"
          >
            <empty-rule-name
              v-if="rule.rule_type === $options.ruleTypeAnyApprover"
              :eligible-approvers-docs-path="eligibleApproversDocsPath"
            />
            <span v-else>{{ summaryText(rule) }}</span>
            <user-avatar-list
              v-if="!rule.fallback"
              class="mt-2"
              :items="rule.approvers"
              :img-size="24"
              empty-text=""
            />
            <div
              v-if="glFeatures.approvalsCommentedBy && rule.commented_by.length > 0"
              class="mt-2"
            >
              <span>{{ s__('MRApprovals|Commented by') }}</span>
              <user-avatar-list
                class="d-inline-block align-middle"
                :items="rule.commented_by"
                :img-size="24"
              />
            </div>
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
        <td
          v-if="rule.rule_type !== $options.ruleTypeAnyApprover"
          :class="glFeatures.approvalsCommentedBy ? 'd-md-table-cell' : 'd-sm-table-cell'"
          class="d-none js-approvers"
        >
          <div><user-avatar-list :items="rule.approvers" :img-size="24" empty-text="" /></div>
        </td>
        <td
          :class="glFeatures.approvalsCommentedBy ? 'd-md-table-cell' : 'd-sm-table-cell'"
          class="w-0 d-none text-nowrap js-pending"
        >
          {{ pendingApprovalsText(rule) }}
        </td>
        <td
          v-if="glFeatures.approvalsCommentedBy"
          :class="glFeatures.approvalsCommentedBy ? 'd-md-table-cell' : 'd-sm-table-cell'"
          class="d-none js-commented-by"
        >
          <user-avatar-list :items="rule.commented_by" :img-size="24" empty-text="" />
        </td>
        <td class="d-none d-md-table-cell js-approved-by">
          <user-avatar-list :items="rule.approved_by" :img-size="24" empty-text="" />
        </td>
      </tr>
    </tbody>
  </table>
</template>
