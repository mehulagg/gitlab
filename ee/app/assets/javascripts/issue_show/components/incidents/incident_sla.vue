<script>
import { GlIcon } from '@gitlab/ui';
import ServiceLevelAgreement from 'ee_component/vue_shared/components/incidents/service_level_agreement.vue';
import { isValidSlaDueAt } from 'ee/vue_shared/components/incidents/utils';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import { formatTime, calculateRemainingMilliseconds } from '~/lib/utils/datetime_utility';
import getSlaDueAt from './graphql/queries/get_sla_due_at.graphql';

export default {
  components: { GlIcon, ServiceLevelAgreement },
  inject: ['fullPath', 'iid', 'slaFeatureAvailable'],
  apollo: {
    slaDueAt: {
      query: getSlaDueAt,
      variables() {
        return {
          fullPath: this.fullPath,
          iid: this.iid,
        };
      },
      update(data) {
        return data?.project?.issue?.slaDueAt;
      },
      result({ data }) {
        const isValidSla = isValidSlaDueAt(data?.project?.issue?.slaDueAt);

        // Render component
        this.hasData = isValidSla;

        // Render parent component
        this.$emit('update', isValidSla);
      },
      error() {
        createFlash({
          message: s__('Incident|There was an issue loading incident data. Please try again.'),
        });
      },
    },
  },
  data() {
    return {
      slaDueAt: null,
      hasData: false,
    };
  },
  computed: {
    displayValue() {
      const time = formatTime(calculateRemainingMilliseconds(this.slaDueAt));

      // remove the seconds portion of the string
      return time.substring(0, time.length - 3);
    },
  },
};
</script>

<template>
  <div v-if="slaFeatureAvailable && hasData">
    <span class="gl-font-weight-bold">{{ s__('HighlightBar|Time to SLA:') }}</span>
    <span class="gl-white-space-nowrap">
      <gl-icon name="timer" />
      <service-level-agreement :sla-due-at="slaDueAt" />
    </span>
  </div>
</template>
