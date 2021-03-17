<script>
import { GlCollapse, GlIcon } from '@gitlab/ui';
import EvidenceItem from './evidence_item.vue';
import EvidenceRow from './evidence_row.vue';

export default {
  components: {
    GlCollapse,
    GlIcon,
    EvidenceItem,
    EvidenceRow,
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
  computed: {
    detailsEntries() {
      return Object.entries(this.details);
    },
  },
  methods: {
    toggleShowSection() {
      this.showSection = !this.showSection;
    },
    isLastRow(i) {
      return i === this.detailsEntries.length - 1;
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
      <evidence-row
        v-for="([label, item], i) in detailsEntries"
        :key="label"
        :label="item.name"
        :is-last-row="isLastRow(i)"
        :debug="i"
      >
        <evidence-item :item="item" />
      </evidence-row>
    </gl-collapse>
  </section>
</template>
