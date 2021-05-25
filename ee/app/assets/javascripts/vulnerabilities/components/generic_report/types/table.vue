<script>
import { GlTable } from '@gitlab/ui';

export default {
  components: {
    GlTable,
    ReportItem: () => import('../report_item.vue'),
  },
  inheritAttrs: false,
  props: {
    header: {
      type: Array,
      required: true,
    },
    rows: {
      type: Array,
      required: true,
    },
  },
  computed: {
    fields() {
      const addKey = (headerItem, index) => ({
        ...headerItem,
        key: this.getKeyForIndex(index),
      });

      return this.header.map(addKey);
    },
    items() {
      const getCellEntry = (cell, index) => [this.getKeyForIndex(index), cell];
      const cellsArrayToObject = (cells) => Object.fromEntries(cells.map(getCellEntry));

      return this.rows.map(cellsArrayToObject);
    },
  },
  methods: {
    getKeyForIndex(index) {
      return `column_${index}`;
    },
  },
};
</script>
<template>
  <gl-table
    :items="items"
    :fields="fields"
    bordered
    borderless
    thead-class="gl-border-t-0 gl-border-b-solid gl-border-b-1 gl-border-b-gray-100"
  >
    <template #head()="data">
      <report-item :item="data.field" />
    </template>
    <template #cell()="data">
      <report-item :item="data.value" />
    </template>
  </gl-table>
</template>
