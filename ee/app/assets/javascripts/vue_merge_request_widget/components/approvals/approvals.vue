<script>
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import createFlash, { hideFlash } from '~/flash';
import { s__ } from '~/locale';
import eventHub from '~/vue_merge_request_widget/event_hub';
import MrWidgetContainer from '~/vue_merge_request_widget/components/mr_widget_container.vue';
import MrWidgetIcon from '~/vue_merge_request_widget/components/mr_widget_icon.vue';
import ApprovalsSummary from './approvals_summary.vue';
import ApprovalsSummaryOptional from './approvals_summary_optional.vue';
import ApprovalsFooter from './approvals_footer.vue';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import Approvals from '~/vue_merge_request_widget/components/approvals/approvals.vue';
import approvalsMixin from '~/vue_merge_request_widget/mixins/approvals';
import ApprovalsAuth from './approvals_auth.vue';
import { FETCH_ERROR } from '~/vue_merge_request_widget/components/approvals/messages';
import ApprovalsFooter from './approvals_footer.vue';

export default {
  name: 'MRWidgetMultipleRuleApprovals',
  components: {
    Approvals,
    ApprovalsAuth,
    GlButton,
    GlLoadingIcon,
    ApprovalsFooter,
  },
  mixins: [approvalsMixin],
  props: {
    mr: {
      type: Object,
      required: true,
    },
    service: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      isLoadingRules: false,
      isExpanded: false,
      modalId: 'approvals-auth',
    };
  },
  computed: {
    isBasic() {
      return this.mr.approvalsWidgetType === 'base';
    },
    approvals() {
      return this.mr.approvals || {};
    },
    approvedBy() {
      return this.approvals.approved_by ? this.approvals.approved_by.map(x => x.user) : [];
    },
    approvalsRequired() {
      return (!this.isBasic && this.approvals.approvals_required) || 0;
    },
    isOptional() {
      return !this.approvedBy.length && !this.approvalsRequired;
    },
    hasFooter() {
      return Boolean(this.mr.approvals);
    },
    requirePasswordToApprove() {
      return this.mr.approvals.require_password_to_approve;
    },
    approvalText() {
      return this.isApproved && this.approvedBy.length > 0
        ? s__('mrWidget|Approve additionally')
        : s__('mrWidget|Approve');
    },
    action() {
      // Use the default approve action, only if we aren't using the auth component for it
      if (this.showApprove) {
        const inverted = this.isApproved;
        return {
          text: this.approvalText,
          inverted,
          variant: 'info',
          action: () => this.approve(),
        };
      } else if (this.showUnapprove) {
        return {
          text: s__('mrWidget|Revoke approval'),
          variant: 'warning',
          inverted: true,
          action: () => this.unapprove(),
        };
      }

      return null;
    },
    hasAction() {
      return Boolean(this.action);
      return !this.isBasic && this.approvals.require_password_to_approve;
    },
  },
  watch: {
    isExpanded(val) {
      if (val) {
        this.refreshAll();
      }
    },
  },
  methods: {
    refreshAll() {
      if (this.isBasic) return Promise.resolve();

      return Promise.all([this.refreshRules(), this.refreshApprovals()]).catch(() =>
        createFlash(FETCH_ERROR),
      );
    },
    refreshRules() {
      if (this.isBasic) return Promise.resolve();

      this.$root.$emit('bv::hide::modal', this.modalId);

      this.isLoadingRules = true;

      return this.service.fetchApprovalSettings().then(settings => {
        this.mr.setApprovalRules(settings);
        this.isLoadingRules = false;
      });
    },
  },
};
</script>
<template>
  <mr-widget-container>
    <div class="js-mr-approvals d-flex align-items-start align-items-md-center">
      <mr-widget-icon name="approval" />
      <div v-if="fetchingApprovals">{{ $options.FETCH_LOADING }}</div>
      <template v-else>
        <approvals-auth
          :is-approving="isApproving"
          :has-error="hasApprovalAuthError"
          :modal-id="modalId"
          @approve="approveWithAuth"
          @hide="clearError"
        />
        <gl-button
          v-if="action"
          :variant="action.variant"
          :class="{ 'btn-inverted': action.inverted }"
          category="secondary"
          class="mr-3"
          data-qa-selector="approve_button"
          @click="action.action"
        >
          <gl-loading-icon v-if="isApproving" inline />
          {{ action.text }}
        </gl-button>
        <approvals-summary-optional
          v-if="isOptional"
          :can-approve="hasAction"
          :help-path="mr.approvalsHelpPath"
        />
        <approvals-summary
          v-else
          :approved="isApproved"
          :approvals-left="approvals.approvals_left"
          :rules-left="approvals.approvalRuleNamesLeft"
          :approvers="approvedBy"
        />
      </template>
    </div>
    <approvals-footer
      v-if="hasFooter"
      slot="footer"
      v-model="isExpanded"
      :suggested-approvers="approvals.suggested_approvers"
      :approval-rules="mr.approvalRules"
      :is-loading-rules="isLoadingRules"
      :security-approvals-help-page-path="mr.securityApprovalsHelpPagePath"
      :eligible-approvers-docs-path="mr.eligibleApproversDocsPath"
    />
  </mr-widget-container>
  <approvals
    :mr="mr"
    :service="service"
    :is-optional-default="isOptional"
    :require-password-to-approve="requirePasswordToApprove"
    :modal-id="modalId"
    @updated="refreshRules"
  >
    <template v-if="!isBasic" #default="{ isApproving, approveWithAuth, hasApprovalAuthError }">
      <approvals-auth
        :is-approving="isApproving"
        :has-error="hasApprovalAuthError"
        :modal-id="modalId"
        @approve="approveWithAuth"
        @hide="clearError"
      />
    </template>
    <template v-if="!isBasic" #footer>
      <approvals-footer
        v-if="hasFooter"
        v-model="isExpanded"
        :suggested-approvers="approvals.suggested_approvers"
        :approval-rules="mr.approvalRules"
        :is-loading-rules="isLoadingRules"
        :security-approvals-help-page-path="mr.securityApprovalsHelpPagePath"
        :eligible-approvers-docs-path="mr.eligibleApproversDocsPath"
      />
    </template>
  </approvals>
</template>
