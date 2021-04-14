<script>
import { groupBy, isNumber } from 'lodash';
import { mapState, mapActions } from 'vuex';
import { isSafeURL } from '~/lib/utils/url_utility';
import { sprintf, __, s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import {
  TYPE_USER,
  TYPE_GROUP,
  TYPE_HIDDEN_GROUPS,
  RULE_TYPE_EXTERNAL_APPROVAL,
  RULE_TYPE_USER_OR_GROUP_APPROVER,
} from '../constants';
import ApproverTypeSelect from './approver_type_select.vue';
import ApproversList from './approvers_list.vue';
import ApproversSelect from './approvers_select.vue';
import BranchesSelect from './branches_select.vue';

const DEFAULT_NAME = 'Default';
const DEFAULT_NAME_FOR_LICENSE_REPORT = 'License-Check';
const DEFAULT_NAME_FOR_VULNERABILITY_CHECK = 'Vulnerability-Check';
const READONLY_NAMES = [DEFAULT_NAME_FOR_LICENSE_REPORT, DEFAULT_NAME_FOR_VULNERABILITY_CHECK];

function mapServerResponseToValidationErrors(messages) {
  return Object.entries(messages).flatMap(([key, msgs]) => msgs.map((msg) => `${key} ${msg}`));
}

export default {
  components: {
    ApproversList,
    ApproversSelect,
    BranchesSelect,
    ApproverTypeSelect,
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
    const defaults = {
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

    return defaults;
  },
  computed: {
    ...mapState(['settings']),
    showApproverTypeSelect() {
      return (
        this.glFeatures.ffComplianceApprovalGates &&
        !this.isEditing &&
        !this.isMrEdit &&
        !READONLY_NAMES.includes(this.name)
      );
    },
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
    validation() {
      if (!this.showValidation) {
        return {};
      }

      const invalidObject = {
        name: this.invalidName,
      };

      if (!this.isMrEdit) {
        invalidObject.branches = this.invalidBranches;
      }

      if (this.isExternalApprovalRule) {
        invalidObject.externalUrl = this.invalidApprovalGateUrl;
      } else {
        invalidObject.approvers = this.invalidApprovers;
        invalidObject.approvalsRequired = this.invalidApprovalsRequired;
      }

      return invalidObject;
    },
    invalidApprovalGateUrl() {
      let error = '';

      if (this.serverValidationErrors.includes('External url has already been taken')) {
        error = __('External url has already been taken');
      } else if (!this.externalUrl || !isSafeURL(this.externalUrl)) {
        error = __('Please provide a valid URL');
      }

      return error;
    },
    invalidName() {
      let error = '';

      if (this.isMultiSubmission) {
        if (this.serverValidationErrors.includes('name has already been taken')) {
          error = __('Rule name is already taken.');
        } else if (!this.name) {
          error = __('Please provide a name');
        }
      }

      return error;
    },
    invalidApprovalsRequired() {
      if (!isNumber(this.approvalsRequired)) {
        return __('Please enter a valid number');
      }

      if (this.approvalsRequired < 0) {
        return __('Please enter a non-negative number');
      }

      return this.approvalsRequired < this.minApprovalsRequired
        ? sprintf(__('Please enter a number greater than %{number} (from the project settings)'), {
            number: this.minApprovalsRequired,
          })
        : '';
    },
    invalidApprovers() {
      if (!this.isMultiSubmission) {
        return '';
      }

      return !this.approvers.length ? __('Please select and add a member') : '';
    },
    invalidBranches() {
      if (this.isMrEdit) return '';

      const invalidTypes = this.branches.filter((id) => typeof id !== 'number');

      return invalidTypes.length ? __('Please select a valid target branch') : '';
    },
    isValid() {
      return Object.keys(this.validation).every((key) => !this.validation[key]);
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
    isNameVisible() {
      return !this.settings.lockedApprovalsRuleName;
    },
    isNameDisabled() {
      return (
        Boolean(this.isPersisted || this.defaultRuleName) && READONLY_NAMES.includes(this.name)
      );
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
        protectedBranchIds: this.branches,
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
    showProtectedBranch() {
      return !this.isMrEdit && this.settings.allowMultiRule;
    },
    approvalGateLabel() {
      return this.isEditing ? this.$options.i18n.approvalGate : this.$options.i18n.addApprovalGate;
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
    submit() {
      let submission;

      this.serverValidationErrors = [];

      if (!this.validate()) {
        submission = Promise.resolve();
      } else if (this.isFallbackSubmission) {
        submission = this.submitFallback();
      } else if (!this.isMultiSubmission) {
        submission = this.submitSingleRule();
      } else {
        submission = this.submitRule();
      }

      submission.catch((failureResponse) => {
        if (this.isExternalApprovalRule) {
          this.serverValidationErrors = failureResponse?.response?.data?.message || [];
        } else {
          this.serverValidationErrors = mapServerResponseToValidationErrors(
            failureResponse?.response?.data?.message || {},
          );
        }
      });

      return submission;
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
    validate() {
      this.showValidation = true;

      return this.isValid;
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
          branches: this.initRule.protectedBranches?.map((x) => x.id) || [],
          ruleType: this.initRule.ruleType,
          approvers: [],
        };
      }

      const { containsHiddenGroups = false, removeHiddenGroups = false } = this.initRule;

      const users = this.initRule.users.map((x) => ({ ...x, type: TYPE_USER }));
      const groups = this.initRule.groups.map((x) => ({ ...x, type: TYPE_GROUP }));
      const branches = this.initRule.protectedBranches?.map((x) => x.id) || [];

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
    approvalGate: s__('ApprovalRule|Approvel gate'),
    addApprovalGate: s__('ApprovalRule|Add approvel gate'),
  },
  approverTypeOptions: [
    { type: RULE_TYPE_USER_OR_GROUP_APPROVER, text: s__('ApprovalRule|Users or groups') },
    { type: RULE_TYPE_EXTERNAL_APPROVAL, text: s__('ApprovalRule|Approval service API') },
  ],
};
</script>

<template>
  <form novalidate @submit.prevent.stop="submit">
    <div v-if="isNameVisible" class="form-group gl-form-group">
      <label class="col-form-label">{{ s__('ApprovalRule|Rule name') }}</label>
      <input
        v-model="name"
        :class="{ 'is-invalid': validation.name }"
        :disabled="isNameDisabled"
        class="gl-form-input form-control"
        name="name"
        type="text"
        data-qa-selector="rule_name_field"
      />
      <span class="invalid-feedback">{{ validation.name }}</span>
      <small class="form-text text-gl-muted">
        {{ s__('ApprovalRule|Examples: QA, Security.') }}
      </small>
    </div>
    <div v-if="showProtectedBranch" class="form-group gl-form-group">
      <label class="col-form-label">{{ s__('ApprovalRule|Target branch') }}</label>
      <branches-select
        v-model="branchesToAdd"
        :project-id="settings.projectId"
        :is-invalid="Boolean(validation.branches)"
        :init-rule="rule"
      />
      <span class="invalid-feedback">{{ validation.branches }}</span>
      <small class="form-text text-gl-muted">
        {{ __('Apply this approval rule to any branch or a specific protected branch.') }}
      </small>
    </div>
    <div v-if="showApproverTypeSelect" class="form-group gl-form-group">
      <label class="col-form-label">{{ s__('ApprovalRule|Approver Type') }}</label>
      <approver-type-select
        v-model="ruleType"
        :approver-type-options="$options.approverTypeOptions"
      />
    </div>
    <div v-if="!isExternalApprovalRule" class="form-group gl-form-group">
      <label class="col-form-label">{{ s__('ApprovalRule|Approvals required') }}</label>
      <input
        v-model.number="approvalsRequired"
        :class="{ 'is-invalid': validation.approvalsRequired }"
        class="gl-form-input form-control mw-6em"
        name="approvals_required"
        type="number"
        :min="minApprovalsRequired"
        data-qa-selector="approvals_required_field"
      />
      <span class="invalid-feedback">{{ validation.approvalsRequired }}</span>
    </div>
    <div v-if="!isExternalApprovalRule" class="form-group gl-form-group">
      <label class="col-form-label">{{ s__('ApprovalRule|Add approvers') }}</label>
      <approvers-select
        v-model="approversToAdd"
        :project-id="settings.projectId"
        :skip-user-ids="userIds"
        :skip-group-ids="groupIds"
        :is-invalid="Boolean(validation.approvers)"
        data-qa-selector="member_select_field"
      />
      <span class="invalid-feedback">{{ validation.approvers }}</span>
    </div>
    <div v-if="isExternalApprovalRule" class="form-group gl-form-group">
      <label class="col-form-label">{{ approvalGateLabel }}</label>
      <input
        v-model="externalUrl"
        :class="{ 'is-invalid': validation.externalUrl }"
        class="gl-form-input form-control"
        name="approval_gate_url"
        type="url"
        data-qa-selector="external_url_field"
      />
      <span class="invalid-feedback">{{ validation.externalUrl }}</span>
      <small class="form-text text-gl-muted">
        {{ s__('ApprovalRule|Invoke an external API as part of the approvals') }}
      </small>
    </div>
    <div v-if="!isExternalApprovalRule" class="bordered-box overflow-auto h-12em">
      <approvers-list v-model="approvers" />
    </div>
  </form>
</template>
