<script>
import { GlSkeletonLoader } from '@gitlab/ui';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { copySubscriptionIdButtonText } from '../constants';

export default {
  i18n: {
    copySubscriptionIdButtonText,
  },
  name: 'SubscriptionDetailsTable',
  components: {
    ClipboardButton,
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
      :key="detail.label"
      :class="{ 'gl-mb-3': isNotLast(index) }"
      class="gl-display-flex"
    >
      <p class="gl-font-weight-bold gl-m-0" data-testid="details-label">{{ detail.label }}:</p>
      <p class="gl-m-0 gl-ml-4" data-testid="details-content">{{ detail.value }}</p>
      <clipboard-button
        v-if="detail.canCopy"
        :text="detail.value"
        :title="$options.i18n.copySubscriptionIdButtonText"
        category="tertiary"
        class="gl-ml-2"
        size="small"
      />
    </li>
  </ul>
</template>
