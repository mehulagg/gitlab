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
      visible: false,
    };
  },
  computed: {
    toggleIcon() {
      return this.visible ? 'chevron-down' : 'chevron-right';
    },
    featureFlag() {
      return gon.features?.mergeRequestReviewers;
    },
  },
};
</script>

<template>
  <div v-if="featureFlag" class="gl-mt-1">
    <gl-button v-collapse-toggle="collapseId" variant="link">
      <gl-icon :name="toggleIcon" />
      {{ __('Approval rules') }}
    </gl-button>

    <gl-collapse :id="collapseId" v-model="visible" class="gl-mt-3 gl-ml-1 gl-mb-5">
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
