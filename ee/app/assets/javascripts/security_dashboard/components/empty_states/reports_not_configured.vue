<script>
import { GlEmptyState, GlLink } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlEmptyState,
    GlLink,
  },
  inject: ['emptyStateSvgPath'],
  props: {
    helpPath: {
      type: String,
      required: true,
    },
  },
  i18n: {
    description: s__(
      'SecurityReports|The latest security findings for your project are displayed here. Use it to find and fix vulnerabilities.',
    ),
  },
};
</script>

<template>
  <gl-empty-state
    :title="s__('SecurityReports|Monitor vulnerabilities in your code')"
    :svg-path="emptyStateSvgPath"
  >
    <template #description>
      {{ $options.i18n.description }}
      <gl-link :href="helpPath">{{ __('More information') }}</gl-link>
    </template>
  </gl-empty-state>
</template>
