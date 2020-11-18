<script>
import { GlCard, GlSprintf } from '@gitlab/ui';

export default {
  cardBodyClass: 'gl-text-center gl-py-3 gl-font-size-h2',
  cardClass: 'gl-bg-gray-10 gl-border-0',
  components: {
    GlCard,
    GlSprintf,
  },
  props: {
    columns: {
      type: Array,
      required: false,
      default: () => [],
    },
    total: {
      type: Number,
      required: true,
    },
  },
  methods: {
    percent(val) {
      if (!this.total) return 0;
      return ((val / this.total) * 100).toFixed(0);
    },
  },
};
</script>

<template>
  <div class="row gl-mt-6">
    <div v-for="(column, index) in columns" :key="index" class="col-sm-4">
      <gl-card :class="$options.cardClass" :body-class="$options.cardBodyClass" class="gl-mb-5">
        <span class="gl-border-1 gl-border-r-solid gl-border-gray-100 gl-pr-3 gl-mr-2">
          <span>{{ column.title }}</span>
          <span class="gl-font-weight-bold"
            >{{ percent(column.value) }}<small class="gl-text-gray-500">%</small></span
          >
        </span>
        <gl-sprintf v-if="total > 0" :message="__('%{count} of %{total}')">
          <template #count>
            <span class="gl-font-weight-bold">{{ column.value }}</span>
          </template>
          <template #total>
            <span class="gl-font-weight-bold">{{ total }}</span>
          </template>
        </gl-sprintf>
      </gl-card>
    </div>
  </div>
</template>
