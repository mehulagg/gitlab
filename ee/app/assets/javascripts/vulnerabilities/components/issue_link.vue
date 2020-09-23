<script>
import { GlIcon, GlLink, GlTooltipDirective } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    issue: {
      type: Object,
      required: true,
    },
  },
  STATE_OPENED: 'opened',
};
</script>
<template>
  <gl-link
    v-gl-tooltip="issue.title"
    :href="issue.webUrl"
    :data-testid="`issue-link-${issue.iid}`"
    class="d-inline-flex align-items-center ml-2 gl-flex-shrink-0"
  >
    <gl-icon
      class="mr-1"
      :class="{ cgreen: issue.state === $options.STATE_OPENED }"
      :name="issue.state === $options.STATE_OPENED ? 'issue-open-m' : 'issue-close'"
    />
    #{{ issue.iid }}
  </gl-link>
</template>
