<script>
import { GlButton, GlLink, GlSprintf } from '@gitlab/ui';
import RuleName from 'ee/approvals/components/rule_name.vue';

export default {
  components: {
    GlButton,
    GlLink,
    GlSprintf,
    RuleName,
  },
  props: {
    rule: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <tr>
    <!-- Suggested approval rule creation row -->
    <template v-if="rule.hasConfiguredJob">
      <td class="js-name" colspan="4">
        <rule-name :name="rule.name" />

        <div class="gl-text-gray-500">
          <gl-sprintf :message="rule.enableDescription">
            <template #link="{ content }">
              <gl-link :href="rule.docsPath" target="_blank">{{ content }}</gl-link>
            </template>
          </gl-sprintf>
        </div>
      </td>
      <td class="gl-px-2! gl-text-right">
        <gl-button @click="$emit('enable')">
          {{ __('Enable') }}
        </gl-button>
      </td>
    </template>

    <!-- Approval rule suggestion when lacking appropriate CI job for the rule -->
    <td v-else class="js-name" colspan="5">
      <rule-name :name="rule.name" />

      <div class="gl-text-gray-500">
        <gl-sprintf :message="rule.description">
          <template #link="{ content }">
            <gl-link :href="rule.docsPath" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </div>
    </td>
  </tr>
</template>
