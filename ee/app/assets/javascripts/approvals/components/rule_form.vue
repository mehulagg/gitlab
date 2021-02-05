<script>
import { mapState, mapActions } from 'vuex';
import { groupBy, isNumber } from 'lodash';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { sprintf, __ } from '~/locale';
import { TYPE_USER, TYPE_GROUP, TYPE_HIDDEN_GROUPS } from '../constants';
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
  },
  // TODO: Remove feature flag in https://gitlab.com/gitlab-org/gitlab/-/issues/235114
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
      name: '',
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
      ...this.getInitialData(),
    };
    // TODO: Remove feature flag in https://gitlab.com/gitlab-org/gitlab/-/issues/235114
    if (this.glFeatures.approvalSuggestions) {
      return { ...defaults, name: this.defaultRuleName || defaults.name };
    }

    return defaults;
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
    validation() {
      if (!this.showValidation) {
        return {};
      }

      const invalidObject = {
        name: this.invalidName,
        approvalsRequired: this.invalidApprovalsRequired,
        approvers: this.invalidApprovers,
      };

      if (!this.isMrEdit) {
        invalidObject.branches = this.invalidBranches;
      }

      return invalidObject;
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
      // TODO: Remove feature flag in https://gitlab.com/gitlab-org/gitlab/-/issues/235114
      if (this.glFeatures.approvalSuggestions) {
        return (
          Boolean(this.isPersisted || this.defaultRuleName) && READONLY_NAMES.includes(this.name)
        );
      }
      return this.isPersisted && READONLY_NAMES.includes(this.name);
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
    showProtectedBranch() {
      return !this.isMrEdit && this.settings.allowMultiRule;
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
        this.serverValidationErrors = mapServerResponseToValidationErrors(
          failureResponse?.response?.data?.message || {},
        );
      });

      return submission;
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

      const { containsHiddenGroups = false, removeHiddenGroups = false } = this.initRule;

      const users = this.initRule.users.map((x) => ({ ...x, type: TYPE_USER }));
      const groups = this.initRule.groups.map((x) => ({ ...x, type: TYPE_GROUP }));
      const branches = this.initRule.protectedBranches?.map((x) => x.id) || [];

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
      };
    },
  },
};
</script>

<template>
  <form novalidate @submit.prevent.stop="submit">
    <div class="row">
      <div v-if="isNameVisible" class="form-group col-sm-6">
        <label class="label-wrapper">
          <span class="mb-2 bold inline">{{ s__('ApprovalRule|Rule name') }}</span>
          <input
            v-model="name"
            :class="{ 'is-invalid': validation.name }"
            :disabled="isNameDisabled"
            class="form-control"
            name="name"
            type="text"
            data-qa-selector="rule_name_field"
          />
          <span class="invalid-feedback">{{ validation.name }}</span>
          <span class="text-secondary">{{ s__('ApprovalRule|e.g. QA, Security, etc.') }}</span>
        </label>
      </div>
      <div class="form-group col-sm-6">
        <label class="label-wrapper">
          <span class="mb-2 bold inline">{{ s__('ApprovalRule|Approvals required') }}</span>
          <input
            v-model.number="approvalsRequired"
            :class="{ 'is-invalid': validation.approvalsRequired }"
            class="form-control mw-6em"
            name="approvals_required"
            type="number"
            :min="minApprovalsRequired"
            data-qa-selector="approvals_required_field"
          />
          <span class="invalid-feedback">{{ validation.approvalsRequired }}</span>
        </label>
      </div>
    </div>
    <div v-if="showProtectedBranch" class="form-group">
      <label class="label-bold">{{ s__('ApprovalRule|Target branch') }}</label>
      <div class="d-flex align-items-start">
        <div class="w-100">
          <branches-select
            v-model="branchesToAdd"
            :project-id="settings.projectId"
            :is-invalid="!!validation.branches"
            :init-rule="rule"
          />
          <div class="invalid-feedback">{{ validation.branches }}</div>
        </div>
      </div>
      <p class="text-muted">
        {{ __('Apply this approval rule to any branch or a specific protected branch.') }}
      </p>
    </div>
    <div class="form-group">
      <label class="label-bold">{{ s__('ApprovalRule|Approvers') }}</label>
      <div class="d-flex align-items-start">
        <div class="w-100" data-qa-selector="member_select_field">
          <approvers-select
            v-model="approversToAdd"
            :project-id="settings.projectId"
            :skip-user-ids="userIds"
            :skip-group-ids="groupIds"
            :is-invalid="!!validation.approvers"
          />
          <div class="invalid-feedback">{{ validation.approvers }}</div>
        </div>
      </div>
    </div>
    <div class="bordered-box overflow-auto h-12em">
      <approvers-list v-model="approvers" />
    </div>
  </form>
</template>
