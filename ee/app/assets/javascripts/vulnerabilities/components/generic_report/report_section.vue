<script>
import { GlCollapse, GlIcon } from '@gitlab/ui';
import ReportItem from './report_item.vue';
import ReportRow from './report_row.vue';
import { isSupportedReportType } from './types/utils';

export default {
  isSupportedReportType,
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
      showSection: false,
    };
  },
  computed: {
    detailsEntries() {
      return Object.entries(this.details);
    },
  },
  methods: {
    toggleShowSection() {
      this.showSection = !this.showSection;
    },
    isLastRow(i) {
      return i === this.detailsEntries.length - 1;
    },
  },
};
</script>

<template>
  <section>
    <header class="gl-display-flex gl-align-items-center">
      <gl-icon name="angle-right" class="gl-mr-2" :class="{ 'gl-rotate-90': showSection }" />
      <h3 class="gl-display-inline gl-my-0! gl-cursor-pointer" @click="toggleShowSection">
        {{ s__('Vulnerability|Evidence') }}
      </h3>
    </header>
    <gl-collapse class="container" :visible="showSection">
      <template v-for="([label, item], i) in detailsEntries">
        <report-row
          v-if="$options.isSupportedReportType(item.type)"
          :key="label"
          :label="item.name"
          :is-last-row="isLastRow(i)"
          :debug="i"
        >
          <report-item :item="item" />
        </report-row>
      </template>
    </gl-collapse>
  </section>
</template>
