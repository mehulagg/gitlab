<script>
import { GlCollapse, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlCollapse,
    GlIcon,
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
    headerIcon() {
      return this.showSection ? 'chevron-down' : 'chevron-right';
    },
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
    <header>
      <h3
        class="gl-display-inline-flex gl-align-items-center gl-mb-0! gl-cursor-pointer"
        @click="toggleShowSection"
      >
        <gl-icon name="angle-right" class="gl-mr-2" :class="{ 'gl-rotate-90': showSection }" />
        {{ s__('Vulnerability|Evidence') }}
      </h3>
    </header>
    <gl-collapse :visible="showSection">
      <div>{{ __('Something is here!') }}</div>
    </gl-collapse>
  </section>
</template>
