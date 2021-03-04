<script>
import { GlEmptyState, GlLink } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlEmptyState,
    GlLink,
  },
  inject: ['dashboardDocumentation', 'emptyStateSvgPath'],
  i18n: {
    description: s__(
      'SecurityReports|The latest security findings for your projects are displayed here. Add projects to your group to view their vulnerabilities here.',
    ),
  },
};
</script>

<template>
  <gl-empty-state
    :title="s__('SecurityReports|Add projects to your group')"
    :svg-path="emptyStateSvgPath"
  >
    <template #description>
      {{ $options.i18n.description }}
      <gl-link :href="dashboardDocumentation">{{ __('More information') }}</gl-link>
    </template>
  </gl-empty-state>
</template>
