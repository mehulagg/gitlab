<script>
import { GlEmptyState, GlButton } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import EscalationPolicy from './escalation_policy.vue';

export const i18n = {
  emptyState: {
    title: s__('EscalationPolicies|Create an escalation policy in GitLab'),
    description: s__(
      "EscalationPolicies|Set up escalation policies to define who is paged, and when, in the event the first users paged don't respond.",
    ),
    button: s__('EscalationPolicies|Add an escalation policy'),
  },
  title: s__('EscalationPolicies|Escalation Policies'),
};

export default {
  i18n,
  components: {
    EscalationPolicy,
    GlEmptyState,
    GlButton,
  },
  inject: ['emptyEscalationPoliciesSvgPath'],
  data() {
    return {
      // TODO: Replace with apollo data
      hasEscalationPolicy: true,
      policies: [
        {
          title: __('Dev on-call escalation'),
          description: __('For when dev on-call schedule fails'),
        },
      ],
    };
  },
  methods: {
    addEscalationPolicy() {
      // TODO: Add method as part of https://gitlab.com/gitlab-org/gitlab/-/issues/268356
    },
  },
};
</script>

<template>
  <div>
    <template v-if="hasEscalationPolicy">
      <h2 class="gl-mb-3">{{ $options.i18n.title }}</h2>
      <escalation-policy v-for="policy in policies" :key="policy.key" :policy="policy" />
    </template>

    <gl-empty-state
      v-else
      :title="$options.i18n.emptyState.title"
      :description="$options.i18n.emptyState.description"
      :svg-path="emptyEscalationPoliciesSvgPath"
    >
      <template #actions>
        <gl-button variant="info" @click="addEscalationPolicy">{{
          $options.i18n.emptyState.button
        }}</gl-button>
      </template>
    </gl-empty-state>
  </div>
</template>
