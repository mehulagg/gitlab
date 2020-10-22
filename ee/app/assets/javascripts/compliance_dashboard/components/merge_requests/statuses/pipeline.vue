<script>
import { GlLink, GlTooltipDirective } from '@gitlab/ui';

import { sprintf, s__ } from '~/locale';
import CiIcon from '~/vue_shared/components/ci_icon.vue';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    CiIcon,
    GlLink,
  },
  props: {
    status: {
      type: Object,
      required: true,
    },
  },
  computed: {
    pipelineCiStatus() {
      return { ...this.status, group: this.status.group || this.status.label };
    },
    pipelineTitle() {
      return sprintf(s__('PipelineStatusTooltip|Pipeline: %{ci_status}'), {
        ci_status: this.status.tooltip,
      });
    },
  },
};
</script>

<template>
  <gl-link :href="pipelineCiStatus.details_path">
    <ci-icon v-gl-tooltip.left="pipelineTitle" class="gl-display-flex" :status="pipelineCiStatus" />
  </gl-link>
</template>
