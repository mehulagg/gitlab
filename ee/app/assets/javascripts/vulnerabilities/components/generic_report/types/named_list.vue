<script>
export default {
  components: {
    ReportItem: () => import('../report_item.vue'),
  },
  inheritAttrs: false,
  props: {
    items: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    hasItems() {
      return this.items.length > 0;
    },
  },
};
</script>

<template>
  <div class="gl-display-table">
    <ul v-if="hasItems" class="generic-report-named-list">
      <li
        v-for="{ label, name, ...values } in items"
        :key="label"
        class="generic-report-named-list-item"
        data-testid="listItem"
      >
        <strong class="generic-report-named-list-label">{{ name }}</strong>
        <span class="generic-report-named-list-value">
          <report-item :item="values" :data-testid="`listValue${label}`" />
        </span>
      </li>
    </ul>
  </div>
</template>
