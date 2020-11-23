<script>
import { GlLink, GlAlert } from '@gitlab/ui';
/**
 * Renders Unmet Prerequisites block for job's view.
 */
export default {
  components: {
    GlLink,
    GlAlert,
  },
  props: {
    helpPath: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <gl-alert
    variant="danger"
    class="gl-mt-3"
    :dismissible="false"
  >
    {{
      s__(`Job|This job failed because the necessary resources were not successfully created.`)
    }}
    <gl-link :href="helpPath" class="js-help-path">
      {{ __('More information') }}
    </gl-link>
  </gl-alert>
</template>
