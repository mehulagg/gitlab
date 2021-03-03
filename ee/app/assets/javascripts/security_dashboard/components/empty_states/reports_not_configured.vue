<script>
import { GlEmptyState } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlEmptyState,
  },
  inject: ['emptyStateSvgPath'],
  props: {
    helpPath: {
      type: String,
      required: true,
    },
  },
  DESCRIPTION: s__(
    `SecurityReports|The security dashboard displays the latest security report. Use it to find and fix vulnerabilities.`,
  ),
};
</script>

<template>
  <gl-empty-state
    :title="s__('SecurityReports|Monitor vulnerabilities in your code')"
    :svg-path="emptyStateSvgPath"
    :description="$options.DESCRIPTION"
    :primary-button-link="helpPath"
    :primary-button-text="__('Learn more')"
  />
</template>
