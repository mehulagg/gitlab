<script>
import { GlLink, GlTooltipDirective } from '@gitlab/ui';
import { formatDate } from '~/lib/utils/datetime_utility';

export default {
  components: {
    GlLink,
    IncidentSla: () => import('ee_component/issue_show/components/incidents/incident_sla.vue'),
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    alert: {
      type: Object,
      required: true,
    },
  },
  computed: {
    startTime() {
      return formatDate(this.alert.startedAt, 'yyyy-mm-dd Z');
    },
    incidentSlaExists() {
      return 'IncidentSla' in this.$options.components;
    },
  },
};
</script>

<template>
  <div
    class="gl-border-solid gl-border-1 gl-border-gray-100 gl-p-5 gl-mb-3 gl-rounded-base gl-display-flex gl-justify-content-space-between gl-xs-flex-direction-column"
  >
    <div class="gl-mr-3">
      <span class="gl-font-weight-bold">{{ s__('HighlightBar|Original alert:') }}</span>
      <gl-link v-gl-tooltip :title="alert.title" :href="alert.detailsUrl">
        #{{ alert.iid }}
      </gl-link>
    </div>

    <div class="gl-mr-3">
      <span class="gl-font-weight-bold">{{ s__('HighlightBar|Alert start time:') }}</span>
      {{ startTime }}
    </div>

    <div :class="{ 'gl-mr-3': incidentSlaExists }">
      <span class="gl-font-weight-bold">{{ s__('HighlightBar|Alert events:') }}</span>
      <span>{{ alert.eventCount }}</span>
    </div>

    <incident-sla />
  </div>
</template>
