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
