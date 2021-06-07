<script>
import { GlFormGroup, GlFormInput } from '@gitlab/ui';
import { groupBy, isEqual, isNumber } from 'lodash';
import { mapState, mapActions } from 'vuex';
import ProtectedBranchesSelector from 'ee/vue_shared/components/branches_selector/protected_branches_selector.vue';
import { isSafeURL } from '~/lib/utils/url_utility';
import { sprintf, __, s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import {
  ANY_BRANCH,
  TYPE_USER,
  TYPE_GROUP,
  TYPE_HIDDEN_GROUPS,
  RULE_TYPE_EXTERNAL_APPROVAL,
  RULE_TYPE_USER_OR_GROUP_APPROVER,
} from '../constants';
import ApproverTypeSelect from './approver_type_select.vue';
import ApproversList from './approvers_list.vue';
import ApproversSelect from './approvers_select.vue';

const DEFAULT_NAME = 'Default';
const DEFAULT_NAME_FOR_LICENSE_REPORT = 'License-Check';
const DEFAULT_NAME_FOR_VULNERABILITY_CHECK = 'Vulnerability-Check';
const READONLY_NAMES = [DEFAULT_NAME_FOR_LICENSE_REPORT, DEFAULT_NAME_FOR_VULNERABILITY_CHECK];

function mapServerResponseToValidationErrors(messages) {
  return Object.entries(messages).flatMap(([key, msgs]) => msgs.map((msg) => `${key} ${msg}`));
}

export default {
  components: {
    ApproverTypeSelect,
    ApproversList,
    ApproversSelect,
    GlFormGroup,
    GlFormInput,
    ProtectedBranchesSelector,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    initRule: {
      type: Object,
      required: false,
      default: null,
    },
    isMrEdit: {
      type: Boolean,
      default: true,
      required: false,
    },
    defaultRuleName: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      name: this.defaultRuleName,
      approvalsRequired: 1,
      minApprovalsRequired: 0,
      externalUrl: null,
      approvers: [],
      approversToAdd: [],
      branches: [],
      branchesToAdd: [],
      showValidation: false,
      isFallback: false,
      containsHiddenGroups: false,
      serverValidationErrors: [],
      ruleType: null,
      ...this.getInitialData(),
    };
  },
  computed: {
    ...mapState(['settings']),
    isExternalApprovalRule() {
      return this.ruleType === RULE_TYPE_EXTERNAL_APPROVAL;
    },
    rule() {
      // If we are creating a new rule with a suggested approval name
      return this.defaultRuleName ? null : this.initRule;
    },
    approversByType() {
      return groupBy(this.approvers, (x) => x.type);
    },
    users() {
      return this.approversByType[TYPE_USER] || [];
    },
    groups() {
      return this.approversByType[TYPE_GROUP] || [];
    },
    userIds() {
      return this.users.map((x) => x.id);
    },
    groupIds() {
      return this.groups.map((x) => x.id);
    },
    invalidStatusChecksUrl() {
      if (this.serverValidationErrors.includes('External url has already been taken')) {
        return this.$options.i18n.validations.externalUrlTaken;
      }

      if (!this.externalUrl || !isSafeURL(this.externalUrl)) {
        return this.$options.i18n.validations.invalidUrl;
      }

      return '';
    },
    invalidName() {
      if (this.isMultiSubmission) {
        if (this.serverValidationErrors.includes('name has already been taken')) {
          return this.$options.i18n.validations.ruleNameTaken;
        }

        if (!this.name) {
          return this.$options.i18n.validations.ruleNameMissing;
        }
      }

      return '';
    },
    invalidApprovalsRequired() {
      if (!isNumber(this.approvalsRequired)) {
        return this.$options.i18n.validations.approvalsRequiredNotNumber;
      }

      if (this.approvalsRequired < 0) {
        return this.$options.i18n.validations.approvalsRequiredNegativeNumber;
      }

      if (this.approvalsRequired < this.minApprovalsRequired) {
        return sprintf(this.$options.i18n.validations.approvalsRequiredMinimum, {
          number: this.minApprovalsRequired,
        });
      }

      return '';
    },
    invalidApprovers() {
      if (this.isMultiSubmission && this.approvers.length <= 0) {
        return this.$options.i18n.validations.approversRequired;
      }

      return '';
    },
    invalidBranches() {
      if (
        !this.isMrEdit &&
        !this.branches.every((branch) => isEqual(branch, ANY_BRANCH) || isNumber(branch?.id))
      ) {
        return this.$options.i18n.validations.branchesRequired;
      }

      return '';
    },
    isValid() {
      return (
        this.isValidName &&
        this.isValidBranches &&
        this.isValidApprovalsRequired &&
        this.isValidApprovers
      );
    },
    isValidExternalApprovalRule() {
      return this.isValidName && this.isValidBranches && this.isValidStatusChecksUrl;
    },
    isValidName() {
      return !this.showValidation || !this.invalidName;
    },
    isValidBranches() {
      return !this.showValidation || !this.invalidBranches;
    },
    isValidApprovalsRequired() {
      return !this.showValidation || !this.invalidApprovalsRequired;
    },
    isValidApprovers() {
      return !this.showValidation || !this.invalidApprovers;
    },
    isValidStatusChecksUrl() {
      return !this.showValidation || !this.invalidStatusChecksUrl;
    },
    isMultiSubmission() {
      return this.settings.allowMultiRule && !this.isFallbackSubmission;
    },
    isFallbackSubmission() {
      return (
        this.settings.allowMultiRule && this.isFallback && !this.name && !this.approvers.length
      );
    },
    isPersisted() {
      return this.initRule && this.initRule.id;
    },
    showApproverTypeSelect() {
      return (
        this.glFeatures.ffComplianceApprovalGates &&
        !this.isEditing &&
        !this.isMrEdit &&
        !READONLY_NAMES.includes(this.name)
      );
    },
    showName() {
      return !this.settings.lockedApprovalsRuleName;
    },
    isNameDisabled() {
      return (
        Boolean(this.isPersisted || this.defaultRuleName) && READONLY_NAMES.includes(this.name)
      );
    },
    showProtectedBranch() {
      return !this.isMrEdit && this.settings.allowMultiRule;
    },
    removeHiddenGroups() {
      return this.containsHiddenGroups && !this.approversByType[TYPE_HIDDEN_GROUPS];
    },
    submissionData() {
      return {
        id: this.initRule && this.initRule.id,
        name: this.settings.lockedApprovalsRuleName || this.name || DEFAULT_NAME,
        approvalsRequired: this.approvalsRequired,
        users: this.userIds,
        groups: this.groupIds,
        userRecords: this.users,
        groupRecords: this.groups,
        removeHiddenGroups: this.removeHiddenGroups,
        protectedBranchIds: this.branches.map((x) => x.id),
      };
    },
    isEditing() {
      return Boolean(this.initRule);
    },
    externalRuleSubmissionData() {
      const { id, name, protectedBranchIds } = this.submissionData;
      return {
        id,
        name,
        protectedBranchIds,
        externalUrl: this.externalUrl,
      };
    },
  },
  watch: {
    approversToAdd(value) {
      this.approvers.push(value[0]);
    },
    branchesToAdd(value) {
      this.branches = value ? [value] : [];
    },
  },
  methods: {
    ...mapActions([
      'putFallbackRule',
      'putExternalApprovalRule',
      'postExternalApprovalRule',
      'postRule',
      'putRule',
      'deleteRule',
      'postRegularRule',
    ]),
    addSelection() {
      if (!this.approversToAdd.length) {
        return;
      }

      this.approvers = this.approversToAdd.concat(this.approvers);
      this.approversToAdd = [];
    },
    /**
     * Validate and submit the form based on what type it is.
     * - Fallback rule?
     * - Single rule?
     * - Multi rule?
     */
    async submit() {
      let submission;

      this.serverValidationErrors = [];
      this.showValidation = true;

      const valid = this.isExternalApprovalRule ? this.isValidExternalApprovalRule : this.isValid;

      if (!valid) {
        submission = Promise.resolve;
      } else if (this.isFallbackSubmission) {
        submission = this.submitFallback;
      } else if (!this.isMultiSubmission) {
        submission = this.submitSingleRule;
      } else {
        submission = this.submitRule;
      }

      try {
        await submission();
      } catch (failureResponse) {
        if (this.isExternalApprovalRule) {
          this.serverValidationErrors = failureResponse?.response?.data?.message || [];
        } else {
          this.serverValidationErrors = mapServerResponseToValidationErrors(
            failureResponse?.response?.data?.message || {},
          );
        }
      }
    },
    /**
     * Submit the rule, by either put-ing or post-ing.
     */
    submitRule() {
      if (this.isExternalApprovalRule) {
        const data = this.externalRuleSubmissionData;
        return data.id ? this.putExternalApprovalRule(data) : this.postExternalApprovalRule(data);
      }

      const data = this.submissionData;

      if (!this.settings.allowMultiRule && this.settings.prefix === 'mr-edit') {
        return data.id ? this.putRule(data) : this.postRegularRule(data);
      }

      return data.id ? this.putRule(data) : this.postRule(data);
    },
    /**
     * Submit as a fallback rule.
     */
    submitFallback() {
      return this.putFallbackRule({ approvalsRequired: this.approvalsRequired });
    },
    /**
     * Submit as a single rule. This is determined by the settings.
     */
    submitSingleRule() {
      if (!this.approvers.length && !this.isExternalApprovalRule) {
        return this.submitEmptySingleRule();
      }

      return this.submitRule();
    },
    /**
     * Submit as a single rule without approvers, so submit the fallback.
     * Also delete the rule if necessary.
     */
    submitEmptySingleRule() {
      const id = this.initRule && this.initRule.id;

      return Promise.all([this.submitFallback(), id ? this.deleteRule(id) : Promise.resolve()]);
    },
    getInitialData() {
      if (!this.initRule || this.defaultRuleName) {
        return {};
      }

      if (this.initRule.isFallback) {
        return {
          approvalsRequired: this.initRule.approvalsRequired,
          isFallback: this.initRule.isFallback,
        };
      }

      if (this.initRule.ruleType === RULE_TYPE_EXTERNAL_APPROVAL) {
        return {
          name: this.initRule.name || '',
          externalUrl: this.initRule.externalUrl,
          branches: this.initRule.protectedBranches || [],
          ruleType: this.initRule.ruleType,
          approvers: [],
        };
      }

      const { containsHiddenGroups = false, removeHiddenGroups = false } = this.initRule;

      const users = this.initRule.users.map((x) => ({ ...x, type: TYPE_USER }));
      const groups = this.initRule.groups.map((x) => ({ ...x, type: TYPE_GROUP }));
      const branches = this.initRule.protectedBranches || [];

      return {
        name: this.initRule.name || '',
        approvalsRequired: this.initRule.approvalsRequired || 0,
        minApprovalsRequired: this.initRule.minApprovalsRequired || 0,
        ruleType: this.initRule.ruleType,
        containsHiddenGroups,
        approvers: groups
          .concat(users)
          .concat(
            containsHiddenGroups && !removeHiddenGroups ? [{ type: TYPE_HIDDEN_GROUPS }] : [],
          ),
        branches,
      };
    },
  },
  i18n: {
    form: {
      addStatusChecks: s__('StatusCheck|API to check'),
      statusChecks: s__('StatusCheck|Status to check'),
      statusChecksDescription: s__('StatusCheck|Invoke an external API as part of the approvals'),
      approvalsRequiredLabel: s__('ApprovalRule|Approvals required'),
      approvalTypeLabel: s__('ApprovalRule|Approver Type'),
      approversLabel: s__('ApprovalRule|Add approvers'),
      nameLabel: s__('ApprovalRule|Rule name'),
      nameDescription: s__('ApprovalRule|Examples: QA, Security.'),
      protectedBranchLabel: s__('ApprovalRule|Target branch'),
      protectedBranchDescription: __(
        'Apply this approval rule to any branch or a specific protected branch.',
      ),
    },
    validations: {
      approvalsRequiredNegativeNumber: __('Please enter a non-negative number'),
      approvalsRequiredNotNumber: __('Please enter a valid number'),
      approvalsRequiredMinimum: __(
        'Please enter a number greater than %{number} (from the project settings)',
      ),
      approversRequired: __('Please select and add a member'),
      branchesRequired: __('Please select a valid target branch'),
      ruleNameTaken: __('Rule name is already taken.'),
      ruleNameMissing: __('Please provide a name'),
      externalUrlTaken: __('External url has already been taken'),
      invalidUrl: __('Please provide a valid URL'),
    },
  },
  approverTypeOptions: [
    { type: RULE_TYPE_USER_OR_GROUP_APPROVER, text: s__('ApprovalRule|Users or groups') },
    { type: RULE_TYPE_EXTERNAL_APPROVAL, text: s__('ApprovalRule|Status check') },
  ],
};
</script>

<template>
  <form novalidate @submit.prevent.stop="submit">
    <gl-form-group
      v-if="showName"
      :label="$options.i18n.form.nameLabel"
      :description="$options.i18n.form.nameDescription"
      :state="isValidName"
      :invalid-feedback="invalidName"
      data-testid="name-group"
    >
      <gl-form-input
        v-model="name"
        :disabled="isNameDisabled"
        :state="isValidName"
        data-qa-selector="rule_name_field"
        data-testid="name"
      />
    </gl-form-group>
    <gl-form-group
      v-if="showProtectedBranch"
      :label="$options.i18n.form.protectedBranchLabel"
      :description="$options.i18n.form.protectedBranchDescription"
      :state="isValidBranches"
      :invalid-feedback="invalidBranches"
      data-testid="branches-group"
    >
      <protected-branches-selector
        v-model="branchesToAdd"
        :project-id="settings.projectId"
        :is-invalid="!isValidBranches"
        :selected-branches="branches"
      />
    </gl-form-group>
    <gl-form-group v-if="showApproverTypeSelect" :label="$options.i18n.form.approvalTypeLabel">
      <approver-type-select
        v-model="ruleType"
        :approver-type-options="$options.approverTypeOptions"
      />
    </gl-form-group>
    <template v-if="!isExternalApprovalRule">
      <gl-form-group
        :label="$options.i18n.form.approvalsRequiredLabel"
        :state="isValidApprovalsRequired"
        :invalid-feedback="invalidApprovalsRequired"
        data-testid="approvals-required-group"
      >
        <gl-form-input
          v-model.number="approvalsRequired"
          :state="isValidApprovalsRequired"
          :min="minApprovalsRequired"
          class="mw-6em"
          type="number"
          data-testid="approvals-required"
          data-qa-selector="approvals_required_field"
        />
      </gl-form-group>
      <gl-form-group
        :label="$options.i18n.form.approversLabel"
        :state="isValidApprovers"
        :invalid-feedback="invalidApprovers"
        data-testid="approvers-group"
      >
        <approvers-select
          v-model="approversToAdd"
          :project-id="settings.projectId"
          :skip-user-ids="userIds"
          :skip-group-ids="groupIds"
          :is-invalid="!isValidApprovers"
          data-qa-selector="member_select_field"
        />
      </gl-form-group>
    </template>
    <gl-form-group
      v-if="isExternalApprovalRule"
      :label="$options.i18n.form.addStatusChecks"
      :description="$options.i18n.form.statusChecksDescription"
      :state="isValidStatusChecksUrl"
      :invalid-feedback="invalidStatusChecksUrl"
      data-testid="status-checks-url-group"
    >
      <gl-form-input
        v-model="externalUrl"
        :state="isValidStatusChecksUrl"
        type="url"
        data-qa-selector="external_url_field"
        data-testid="status-checks-url"
      />
    </gl-form-group>
    <div v-if="!isExternalApprovalRule" class="bordered-box overflow-auto h-12em">
      <approvers-list v-model="approvers" />
    </div>
  </form>
</template>
