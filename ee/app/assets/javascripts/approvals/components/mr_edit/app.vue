<script>
import { uniqueId } from 'lodash';
import {
  GlIcon,
  GlButton,
  GlCollapse,
  GlCollapseToggleDirective,
  GlSafeHtmlDirective,
} from '@gitlab/ui';
import { mapState } from 'vuex';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { __, n__, sprintf } from '~/locale';
import App from '../app.vue';
import MrRules from './mr_rules.vue';
import MrRulesHiddenInputs from './mr_rules_hidden_inputs.vue';

export default {
  components: {
    GlIcon,
    GlButton,
    GlCollapse,
    App,
    MrRules,
    MrRulesHiddenInputs,
  },
  directives: {
    CollapseToggle: GlCollapseToggleDirective,
    SafeHtml: GlSafeHtmlDirective,
  },
  mixins: [glFeatureFlagsMixin()],
  data() {
    return {
      collapseId: uniqueId('approval-rules-expandable-section-'),
      isCollapsed: false,
    };
  },
  computed: {
    ...mapState({
      rules: state => state.approvals.rules,
      canOverride: state => state.settings.canOverride,
    }),
    toggleIcon() {
      return this.isCollapsed ? 'chevron-down' : 'chevron-right';
    },
    isCollapseFeatureEnabled() {
      return this.glFeatures.mergeRequestReviewers && this.glFeatures.mrCollapsedApprovalRules;
    },
    collapsedSummary() {
      if (
        this.rules.length === 1 &&
        this.rules[0].ruleType === 'any_approver' &&
        this.rules[0].approvalsRequired > 0
      ) {
        return sprintf(
          n__(
            '%{strong_start}%d member%{strong_end} must approve to merge. Anyone with role Developer or higher can approve.',
            '%{strong_start}%d members%{strong_end} must approve to merge. Anyone with role Developer or higher can approve.',
            this.rules[0].approvalsRequired,
          ),
          { strong_start: '<strong>', strong_end: '</strong>' },
          false,
        );
      } else if (
        this.rules.length === 2 &&
        (this.rules[1].ruleType === 'regular' || this.rules[1].isNew) &&
        this.rules[1].approvalsRequired > 0
      ) {
        return sprintf(
          n__(
            '%{strong_start}%d eligible member%{strong_end} must approve to merge.',
            '%{strong_start}%d eligible members%{strong_end} must approve to merge.',
            this.rules[1].approvalsRequired,
          ),
          { strong_start: '<strong>', strong_end: '</strong>' },
          false,
        );
      } else if (this.rules.length > 2) {
        return sprintf(
          __(
            '%{strong_start}%{approval_rules} approval rules%{strong_end} require eligible members to approve before merging.',
          ),
          {
            approval_rules: this.rules.length - 1,
            strong_start: '<strong>',
            strong_end: '</strong>',
          },
          false,
        );
      }

      return __('Approvals are optional.');
    },
  },
};
</script>

<template>
  <div v-if="isCollapseFeatureEnabled" class="gl-mt-2">
    <p
      v-safe-html="collapsedSummary"
      class="gl-mb-2 gl-text-gray-500"
      data-testid="collapsedSummaryText"
    ></p>
    <gl-button
      v-if="canOverride"
      v-collapse-toggle="collapseId"
      variant="link"
      button-text-classes="flex"
    >
      <gl-icon :name="toggleIcon" class="mr-1" />
      <span>{{ s__('ApprovalRule|Approval rules') }}</span>
    </gl-button>

    <gl-collapse
      :id="collapseId"
      v-model="isCollapsed"
      class="gl-mt-3 gl-ml-5 gl-mb-5 gl-transition-medium"
    >
      <app>
        <mr-rules slot="rules" />
        <mr-rules-hidden-inputs slot="footer" />
      </app>
    </gl-collapse>
  </div>
  <app v-else>
    <mr-rules slot="rules" />
    <mr-rules-hidden-inputs slot="footer" />
  </app>
</template>
