<script>
import { GlFormGroup, GlFormInput, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { REPORT_TYPES } from 'ee/security_dashboard/store/constants';
import { groupBy, isEqual, isNumber } from 'lodash';
import { mapState, mapActions } from 'vuex';
import ProtectedBranchesSelector from 'ee/vue_shared/components/branches_selector/protected_branches_selector.vue';
import { sprintf, __, s__ } from '~/locale';
import { ANY_BRANCH, TYPE_USER, TYPE_GROUP, TYPE_HIDDEN_GROUPS } from '../constants';
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
  REPORT_TYPES,
  components: {
    ApproversList,
    ApproversSelect,
    GlFormGroup,
    GlFormInput,
    ProtectedBranchesSelector,
    GlDropdown,
    GlDropdownItem,
  },
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
      approvers: [],
      approversToAdd: [],
      branches: [],
      branchesToAdd: [],
      showValidation: false,
      isFallback: false,
      containsHiddenGroups: false,
      serverValidationErrors: [],
      scanners: [],
      ...this.getInitialData(),
    };
  },
  computed: {
    ...mapState(['settings']),
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
    invalidScanners() {
      if (this.scanners.length <= 0) {
        return this.$options.i18n.validations.scannersRequired;
      }

      return '';
    },
    isValid() {
      return (
        this.isValidName &&
        this.isValidBranches &&
        this.isValidApprovalsRequired &&
        this.isValidApprovers &&
        this.areValidScanners
      );
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
    areValidScanners() {
      return !this.showValidation || !this.isVulnerabilityCheck || !this.invalidScanners;
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
        scanners: this.scanners,
      };
    },
    isEditing() {
      return Boolean(this.initRule);
    },
    isVulnerabilityCheck(){
      return DEFAULT_NAME_FOR_VULNERABILITY_CHECK === this.name
    }
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
    ...mapActions(['putFallbackRule', 'postRule', 'putRule', 'deleteRule', 'postRegularRule']),
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

      if (!this.isValid) {
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
        this.serverValidationErrors = mapServerResponseToValidationErrors(
          failureResponse?.response?.data?.message || {},
        );
      }
    },
    /**
     * Submit the rule, by either put-ing or post-ing.
     */
    submitRule() {
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
      if (!this.approvers.length) {
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

      const { containsHiddenGroups = false, removeHiddenGroups = false } = this.initRule;

      const users = this.initRule.users.map((x) => ({ ...x, type: TYPE_USER }));
      const groups = this.initRule.groups.map((x) => ({ ...x, type: TYPE_GROUP }));
      const branches = this.initRule.protectedBranches || [];

      return {
        name: this.initRule.name || '',
        approvalsRequired: this.initRule.approvalsRequired || 0,
        minApprovalsRequired: this.initRule.minApprovalsRequired || 0,
        containsHiddenGroups,
        approvers: groups
          .concat(users)
          .concat(
            containsHiddenGroups && !removeHiddenGroups ? [{ type: TYPE_HIDDEN_GROUPS }] : [],
          ),
        branches,
        scanners: this.initRule.scanners || [],
      };
    },
    isSelectedReport(report_type){
      return this.scanners.includes(report_type)
    },
    setSelectedReport(report_type){
      const index = this.scanners.indexOf(report_type);
      if (index > -1) {
        this.scanners.splice(index, 1);
      }
      else {
        this.scanners.push(report_type);
      }
    },
  },
  i18n: {
    form: {
      approvalsRequiredLabel: s__('ApprovalRule|Approvals required'),
      approvalTypeLabel: s__('ApprovalRule|Approver Type'),
      approversLabel: s__('ApprovalRule|Add approvers'),
      nameLabel: s__('ApprovalRule|Rule name'),
      nameDescription: s__('ApprovalRule|Examples: QA, Security.'),
      protectedBranchLabel: s__('ApprovalRule|Target branch'),
      protectedBranchDescription: __(
        'Apply this approval rule to any branch or a specific protected branch.',
      ),
      scannersLabel: s__('ApprovalRule|Security scanners'),
      scannersSelectLabel: s__('ApprovalRule|Select scanners'),
      scannersDescription: s__('ApprovalRule|Apply this approval rule to consider only the selected security scanners.'),
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
      scannersRequired: __('Please select at least one security scanner'),
    },
  },
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
    <gl-form-group
      v-if="isVulnerabilityCheck"
      :label="$options.i18n.form.scannersLabel"
      :description="$options.i18n.form.scannersDescription"
      :state="areValidScanners"
      :invalid-feedback="invalidScanners"
    >
      <gl-dropdown
      :text=$options.i18n.form.scannersSelectLabel
      >
        <gl-dropdown-item
            v-for="(value, key) in this.$options.REPORT_TYPES"
            :key="key"
            :is-check-item="true"
            :is-checked="isSelectedReport( key )"
            @click="setSelectedReport(key)"
          >
          {{value}}
        </gl-dropdown-item>
      </gl-dropdown>
    </gl-form-group>
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
    <div class="bordered-box overflow-auto h-12em">
      <approvers-list v-model="approvers" />
    </div>
  </form>
</template>
