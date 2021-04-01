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
  computed: {
    hasContent() {
      return this.details.some(({ value }) => Boolean(value));
    },
    placeholderHeight() {
      return `${this.details.length * 25}px`;
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
  <div v-if="!hasContent" :style="{ height: placeholderHeight }">
    <gl-skeleton-loader>
      <rect
        v-for="index in details.length"
        :key="index"
        :y="(index - 1) * 24"
        height="12"
        rx="4"
        width="200"
      />
    </gl-skeleton-loader>
  </div>
  <table v-else class="gl-m-0 gl-p-0">
    <tbody>
      <tr v-for="(detail, index) in details" :key="detail.label">
        <td data-testid="details-label">
          <p :class="{ 'gl-pb-3': isNotLast(index) }" class="gl-font-weight-bold gl-mb-0">
            {{ detail.label }}:
          </p>
        </td>
        <td data-testid="details-content">
          <p :class="{ 'gl-pb-3': isNotLast(index) }" class="gl-mb-0 gl-pl-5">
            {{ detail.value }}
            <clipboard-button
              v-if="detail.canCopy"
              :text="detail.value"
              :title="$options.i18n.copySubscriptionIdButtonText"
              category="tertiary"
              class="gl-ml-2"
              size="small"
            />
          </p>
        </td>
      </tr>
    </tbody>
  </table>
</template>
