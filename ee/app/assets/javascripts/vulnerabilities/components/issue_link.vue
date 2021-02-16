<script>
import jiraLogo from '@gitlab/svgs/dist/illustrations/logos/jira.svg';
import { GlIcon, GlLink, GlTooltipDirective, GlSafeHtmlDirective } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    SafeHtml: GlSafeHtmlDirective,
  },
  props: {
    issue: {
      type: Object,
      required: true,
    },
    isJira: {
      type: Boolean,
      required: false,
    },
  },
  computed: {
    iconName() {
      return this.issue.state === this.$options.STATE_OPENED ? 'issue-open-m' : 'issue-close';
    },
  },
  jiraLogo,
  STATE_OPENED: 'opened',
};
</script>
<template>
  <gl-link
    v-gl-tooltip="issue.title"
    :href="issue.webUrl"
    target="__blank"
    class="gl-display-inline-flex gl-align-items-center gl-flex-shrink-0"
  >
    <span
      v-if="isJira"
      v-safe-html="$options.jiraLogo"
      class="gl-min-h-6 gl-mr-3 gl-display-inline-flex gl-align-items-center"
      data-testid="jira-logo"
    ></span>
    <gl-icon
      v-else
      class="gl-mr-1"
      :class="{ 'gl-text-green-600': issue.state === $options.STATE_OPENED }"
      :name="iconName"
    />
    #{{ issue.iid }}
    <gl-icon v-if="isJira" :size="12" name="external-link" class="gl-ml-1" />
  </gl-link>
</template>
