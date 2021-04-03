<script>
import { GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  i18n: {
    published: s__('IncidentManagement|Published to status page'),
  },
  components: {
    GlIcon,
  },
  props: {
    statusPagePublishedIncident: {
      type: Boolean,
      required: false,
      default: null,
    },
    unPublished: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <div data-testid="published-cell">
    <gl-icon
      v-if="statusPagePublishedIncident"
      name="status_success"
      class="gl-fill-green-500"
      :aria-label="$options.i18n.published"
    />
    <div v-else>{{ unPublished }}</div>
  </div>
</template>
