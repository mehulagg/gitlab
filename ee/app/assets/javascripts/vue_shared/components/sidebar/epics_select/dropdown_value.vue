<script>
import { GlLink } from '@gitlab/ui';

export default {
  components: {
    GlLink,
  },
  props: {
    epic: {
      type: Object,
      required: true,
    },
  },
  computed: {
    hasEpic() {
      return this.epic ? Boolean(this.epic.title && this.epic.url) : false;
    },
  },

  emits: [],
};
</script>

<template>
  <div class="value js-epic-label hide-collapsed">
    <gl-link v-if="hasEpic" :href="epic.url" class="bold">{{ epic.title }}</gl-link>
    <span v-else class="no-value">
      <slot></slot>
    </span>
  </div>
</template>
