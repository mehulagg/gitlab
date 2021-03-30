<script>
import { GlSkeletonLoader } from '@gitlab/ui';

export default {
  name: 'SubscriptionDetailsTable',
  components: {
    GlSkeletonLoader,
  },
  props: {
    details: {
      type: Array,
      required: true,
    },
  },
  methods: {
    isNotLast(index) {
      return index < this.details.length - 1;
    },
  },
};
</script>

<template>
  <div v-if="!details.length">
    <gl-skeleton-loader :lines="1" />
    <gl-skeleton-loader :lines="1" />
  </div>
  <ul v-else class="gl-list-style-none gl-m-0 gl-p-0">
    <li
      v-for="(detail, index) in details"
      :key="index"
      :class="{ 'gl-mb-3': isNotLast(index) }"
      class="gl-display-flex"
    >
      <p class="gl-font-weight-bold gl-m-0" data-testid="details-label">{{ detail.label }}:</p>
      <p class="gl-m-0 gl-ml-4" data-testid="details-content">{{ detail.value }}</p>
    </li>
  </ul>
</template>
