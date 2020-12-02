<script>
import { uniqueId } from 'lodash';
import { GlIcon, GlButton, GlCollapse, GlCollapseToggleDirective } from '@gitlab/ui';
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
  },
  data() {
    return {
      collapseId: uniqueId('approval-rules-expandable-section-'),
      isCollapsed: false,
    };
  },
  computed: {
    toggleIcon() {
      return this.isCollapsed ? 'chevron-down' : 'chevron-right';
    },
    isCollapseFeatureEnabled() {
      return gon.features?.mergeRequestReviewers && gon.features?.mrCollapsedApprovalRules;
    },
  },
};
</script>

<template>
  <div v-if="isCollapseFeatureEnabled" class="gl-mt-2">
    <gl-button v-collapse-toggle="collapseId" variant="link" button-text-classes="flex">
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
