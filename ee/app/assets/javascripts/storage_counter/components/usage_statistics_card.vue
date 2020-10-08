<script>
import { GlLink, GlIcon, GlSprintf } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
    GlLink,
    GlSprintf,
  },
  props: {
    usage: {
      type: Object,
      required: true,
    },
    cssClass: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    hasDenomenator() {
      return Array.isArray(this.usage.size);
    },
    usageSize() {
      if (this.hasDenomenator) {
        const [numerator, denomenator] = this.usage.size;
        return {
          value: numerator.value,
          unit: numerator.unit,
          denomenator,
        };
      } else {
        return {
          value: this.usage.size.value,
          unit: this.usage.size.unit,
        };
      }
    },
  },
};
</script>
<template>
  <div class="gl-p-5 gl-my-5 gl-bg-gray-10 gl-flex-fill-1 gl-white-space-nowrap" :class="cssClass">
    <p class="mb-2">
      <gl-sprintf :message="__('%{size} %{unit}')">
        <template #size>
          <span class="gl-font-size-h-display gl-font-weight-bold">{{ usageSize.value }}</span>
        </template>
        <template #unit>
          <span class="gl-font-lg gl-font-weight-bold">{{ usageSize.unit }}</span>
        </template>
      </gl-sprintf>
      <template v-if="hasDenomenator">
        <span class="gl-font-size-h-display gl-font-weight-bold">/</span>
        <gl-sprintf :message="__('%{size} %{unit}')">
          <template #size>
            <span class="gl-font-size-h-display gl-font-weight-bold">{{
              usageSize.denomenator.value
            }}</span>
          </template>
          <template #unit>
            <span class="gl-font-lg gl-font-weight-bold">{{ usageSize.denomenator.unit }}</span>
          </template>
        </gl-sprintf>
      </template>
    </p>
    <p class="gl-border-b-2 gl-border-b-solid gl-border-b-gray-100 gl-font-weight-bold gl-pb-3">
      {{ usage.description }}
    </p>
    <p class="gl-mb-0">
      <slot v-bind="{ link: usage.link }" name="link">
        <gl-link target="_blank" :href="usage.link.url">
          <span class="text-truncate">{{ usage.link.text }}</span>
          <gl-icon name="external-link" class="gl-ml-2 gl-flex-shrink-0 gl-text-black-normal" />
        </gl-link>
      </slot>
    </p>
  </div>
</template>
