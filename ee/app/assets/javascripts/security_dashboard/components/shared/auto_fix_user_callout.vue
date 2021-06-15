<script>
import { GlBanner } from '@gitlab/ui';

export default {
  name: 'AutoFixUserCallout',
  components: {
    GlBanner,
  },
  props: {
    helpPagePath: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-banner
    :title="s__('AutoRemediation|Introducing GitLab auto-fix')"
    :button-text="__('Learn more')"
    :button-link="helpPagePath"
    variant="introduction"
    v-on="$listeners"
  >
    <p>
      {{
        s__(
          "AutoRemediation|If you're using dependency and/or container scanning, and auto-fix is enabled, auto-fix automatically creates merge requests with fixes to vulnerabilities.",
        )
      }}
    </p>
  </gl-banner>
</template>
