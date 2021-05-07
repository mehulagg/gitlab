<script>
import { GlSkeletonLoader, GlTable } from '@gitlab/ui';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { copySubscriptionIdButtonText } from '../constants';

const placeholderHeightFactor = 32;
const placeholderWidth = 180;
const DEFAULT_TH_CLASSES = 'gl-display-none';
const DEFAULT_TD_CLASSES = 'gl-border-none! gl-h-7 gl-line-height-normal! gl-p-0!';

export default {
  i18n: {
    copySubscriptionIdButtonText,
  },
  fields: [
    {
      key: 'label',
      label: '',
      thClass: DEFAULT_TH_CLASSES,
      tdClass: `${DEFAULT_TD_CLASSES} gl-w-13`,
    },
    {
      key: 'value',
      formatter: (v, k, item) => item.value.toString(),
      label: '',
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASSES,
    },
  ],
  name: 'SubscriptionDetailsTable',
  components: {
    ClipboardButton,
    GlSkeletonLoader,
    GlTable,
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
    placeholderContainerHeight() {
      return this.details.length * placeholderHeightFactor;
    },
    placeholderContainerWidth() {
      return placeholderWidth;
    },
    placeHolderHeight() {
      return placeholderHeightFactor / 2;
    },
  },
  methods: {
    isLastRow(index) {
      return index === this.details.length - 1;
    },
    placeHolderPosition(index) {
      return (index - 1) * placeholderHeightFactor;
    },
  },
};
</script>

<template>
  <gl-table v-if="hasContent" :fields="$options.fields" :items="details" class="gl-m-0!">
    <template #cell(label)="{ item }">
      <p class="gl-font-weight-bold gl-text-gray-800" data-testid="details-label">
        {{ item.label }}:
      </p>
    </template>

    <template #cell(value)="{ item, value }">
      <p class="gl-relative" data-testid="details-content">
        {{ value || '-' }}
        <clipboard-button
          v-if="item.canCopy"
          :text="value"
          :title="$options.i18n.copySubscriptionIdButtonText"
          category="tertiary"
          class="gl-absolute gl-mt-n2 gl-ml-2"
          size="small"
        />
      </p>
    </template>
  </gl-table>
  <div
    v-else
    :style="{ height: `${placeholderContainerHeight}px`, width: `${placeholderContainerWidth}px` }"
    class="gl-pt-2"
  >
    <gl-skeleton-loader :height="placeholderContainerHeight" :width="placeholderContainerWidth">
      <rect
        v-for="index in details.length"
        :key="index"
        :height="placeHolderHeight"
        :width="placeholderContainerWidth"
        :y="placeHolderPosition(index)"
        rx="8"
      />
    </gl-skeleton-loader>
  </div>
</template>
