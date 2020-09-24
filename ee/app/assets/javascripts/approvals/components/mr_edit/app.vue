<script>
import App from '../app.vue';
import MrRules from './mr_rules.vue';
import MrRulesHiddenInputs from './mr_rules_hidden_inputs.vue';

export default {
  components: {
    App,
    MrRules,
    MrRulesHiddenInputs,
  },
};
</script>

<template>
  <app>
    <mr-rules slot="rules" />
    <mr-rules-hidden-inputs slot="footer" />
  </app>
</template>
