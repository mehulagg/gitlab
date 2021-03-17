<script>
import { GlCollapse, GlIcon } from '@gitlab/ui';
import EvidenceItem from './evidence_item.vue';

export default {
  components: {
    GlCollapse,
    GlIcon,
    EvidenceItem,
  },
  props: {
    details: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      showSection: false,
    };
  },
  methods: {
    toggleShowSection() {
      this.showSection = !this.showSection;
    },
  },
};
</script>

<template>
  <section>
    <header class="gl-display-flex gl-align-items-center">
      <gl-icon name="angle-right" class="gl-mr-2" :class="{ 'gl-rotate-90': showSection }" />
      <h3 class="gl-display-inline gl-my-0! gl-cursor-pointer" @click="toggleShowSection">
        {{ s__('Vulnerability|Evidence') }}
      </h3>
    </header>
    <gl-collapse :visible="showSection">
      <evidence-item v-for="[label, item] in Object.entries(details)" :key="label" :item="item" />
    </gl-collapse>
  </section>
</template>
