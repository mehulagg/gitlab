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
  },
};
</script>

<template>
  <!-- SAM: This need to be behind feature flag!!! -->
  <div>
    <div>
      <gl-button v-collapse-toggle="collapseId" variant="link">
        <gl-icon :name="toggleIcon" />
        {{ __('Show approval rules') }}
      </gl-button>

      <gl-collapse :id="collapseId" v-model="visible" class="gl-mt-3">
        <app>
          <mr-rules slot="rules" />
          <mr-rules-hidden-inputs slot="footer" />
        </app>
      </gl-collapse>
    </div>
  </div>
</template>
