<script>
import { GlEmptyState, GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';

export const i18n = {
  emptyState: {
    title: s__('EscalationPolicies|Create an escalation policy in GitLab'),
    description: s__(
      "EscalationPolicies|Set up escalation policies to define who is paged, and when, in the event the first users paged don't respond.",
    ),
    button: s__('EscalationPolicies|Add an escalation policy'),
  },
};

export default {
  i18n,
  components: {
    GlEmptyState,
    GlButton,
  },
  inject: ['emptyEscalationPoliciesSvgPath'],
  methods: {
    addEscalationPolicy() {
      // TODO: Add method as part of https://gitlab.com/gitlab-org/gitlab/-/issues/268356
    },
  },
};
</script>

<template>
  <gl-empty-state
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
</template>
