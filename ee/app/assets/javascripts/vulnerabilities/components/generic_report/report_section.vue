<script>
import { GlCollapse, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import ReportItem from './report_item.vue';
import ReportRow from './report_row.vue';
import { isValidReportType } from './types/utils';

export default {
  i18n: {
    heading: s__('Vulnerability|Evidence'),
  },
  components: {
    GlCollapse,
    GlIcon,
    ReportItem,
    ReportRow,
  },
  props: {
    details: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      showSection: true,
    };
  },
  computed: {
    detailsEntries() {
      return Object.entries(this.details).filter(([, item]) => isValidReportType(item.type));
    },
    hasDetails() {
      return this.detailsEntries.length > 0;
    },
  },
  methods: {
    toggleShowSection() {
      this.showSection = !this.showSection;
    },
  },
};
</script>
<template>
  <section v-if="hasDetails">
    <header class="gl-display-flex gl-align-items-center">
      <gl-icon name="angle-right" class="gl-mr-2" :class="{ 'gl-rotate-90': showSection }" />
      <h3 class="gl-display-inline gl-my-0! gl-cursor-pointer" @click="toggleShowSection">
        {{ $options.i18n.heading }}
      </h3>
    </header>
    <gl-collapse :visible="showSection">
      <div data-testid="reports">
        <template v-for="[label, item] in detailsEntries">
          <report-row :key="label" :label="item.name" :data-testid="`report-row-${label}`">
            <report-item :item="item" />
          </report-row>
        </template>
      </div>
    </gl-collapse>
  </section>
</template>
