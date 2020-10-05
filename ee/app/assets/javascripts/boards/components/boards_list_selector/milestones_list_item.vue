<script>
import { GlButton } from '@gitlab/ui';

export default {
  components: {
    GlButton,
  },
  props: {
    item: {
      type: Object,
      required: true,
    },
  },
  methods: {
    handleItemClick() {
      this.$emit('onItemSelect', this.item);
    },
  },
};
</script>

<template>
  <li>
    <gl-button category="tertiary" class="gl-rounded-0!" @click="handleItemClick">
      <span class="gl-white-space-normal">{{ item.title }}</span>
    </gl-button>
  </li>
</template>
