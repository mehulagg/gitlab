<script>
import { GlSafeHtmlDirective, GlAccordion, GlAccordionItem } from '@gitlab/ui';
import { mapState } from 'vuex';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { __, n__, sprintf, s__ } from '~/locale';
import App from '../app.vue';
import MrRules from './mr_rules.vue';
import MrRulesHiddenInputs from './mr_rules_hidden_inputs.vue';

export default {
  components: {
    GlAccordion,
    GlAccordionItem,
    App,
    MrRules,
    MrRulesHiddenInputs,
  },
  directives: {
    SafeHtml: GlSafeHtmlDirective,
  },
  mixins: [glFeatureFlagsMixin()],
  computed: {
    ...mapState({
      rules: (state) => state.approvals.rules,
      canOverride: (state) => state.settings.canOverride,
    }),
    accordionTitle() {
      return s__('ApprovalRule|Approval rules');
    },
    isCollapseFeatureEnabled() {
      return this.glFeatures.mergeRequestReviewers && this.glFeatures.mrCollapsedApprovalRules;
    },
    hasOptionalRules() {
      return this.rules.every((r) => r.approvalsRequired === 0);
    },
    requiredRules() {
      return this.rules.reduce((acc, rule) => {
        if (rule.approvalsRequired > 0) {
          acc.push(rule);
        }

        return acc;
      }, []);
    },
    collapsedSummary() {
      const rulesLength = this.requiredRules.length;
      const firstRule = this.requiredRules[0];

      if (this.hasOptionalRules) {
        return __('Approvals are optional.');
      } else if (rulesLength === 1 && firstRule.ruleType === 'any_approver') {
        return sprintf(
          n__(
            '%{strong_start}%{count} member%{strong_end} must approve to merge. Anyone with role Developer or higher can approve.',
            '%{strong_start}%{count} members%{strong_end} must approve to merge. Anyone with role Developer or higher can approve.',
            firstRule.approvalsRequired,
          ),
          {
            strong_start: '<strong>',
            strong_end: '</strong>',
            count: firstRule.approvalsRequired,
          },
          false,
        );
      } else if (rulesLength === 1 && firstRule.ruleType !== 'any_approver') {
        return sprintf(
          n__(
            '%{strong_start}%{count} eligible member%{strong_end} must approve to merge.',
            '%{strong_start}%{count} eligible members%{strong_end} must approve to merge.',
            firstRule.approvalsRequired,
          ),
          {
            strong_start: '<strong>',
            strong_end: '</strong>',
            count: firstRule.approvalsRequired,
          },
          false,
        );
      } else if (rulesLength > 1) {
        return sprintf(
          n__(
            '%{strong_start}%{count} approval rule%{strong_end} requires eligible members to approve before merging.',
            '%{strong_start}%{count} approval rules%{strong_end} require eligible members to approve before merging.',
            rulesLength,
          ),
          {
            strong_start: '<strong>',
            strong_end: '</strong>',
            count: rulesLength,
          },
          false,
        );
      }

      return null;
    },
  },
};
</script>

<template>
  <div v-if="isCollapseFeatureEnabled" class="gl-mt-2">
    <p
      v-safe-html="collapsedSummary"
      class="gl-mb-0 gl-text-gray-500"
      data-testid="collapsedSummaryText"
    ></p>

    <gl-accordion>
      <gl-accordion-item :title="accordionTitle">
        <app>
          <mr-rules slot="rules" />
          <mr-rules-hidden-inputs slot="footer" />
        </app>
      </gl-accordion-item>
    </gl-accordion>
  </div>
  <app v-else>
    <mr-rules slot="rules" />
    <mr-rules-hidden-inputs slot="footer" />
  </app>
</template>
