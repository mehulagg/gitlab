<script>
export default {
  components: {
    ReportItem: () => import('../report_item.vue'),
  },
  props: {
    items: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    itemsEntries() {
      return Object.entries(this.items);
    },
    hasItems() {
      return this.itemsEntries.length > 0;
    },
  },
};
</script>

<template>
  <dl v-if="hasItems">
    <div v-for="[label, value] in itemsEntries" :key="label">
      <dt>{{ label }}</dt>
      <dd><report-item :item="value" /></dd>
    </div>
  </dl>
</template>
