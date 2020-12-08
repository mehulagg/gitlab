<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    canaryIngress: {
      required: true,
      type: Object,
    },
  },
  ingressOptions: Array(21)
    .fill(0)
    .map((_, i) => i * 5),

  translations: {
    stableLabel: s__('CanaryIngress|Stable'),
    canaryLabel: s__('CanaryIngress|Canary'),
  },

  css: {
    label: [
      'gl-font-base',
      'gl-font-weight-normal',
      'gl-line-height-normal',
      'gl-inset-border-1-gray-200',
      'gl-py-3',
      'gl-px-4',
      'gl-mb-0',
    ],
  },
  computed: {
    stableWeight() {
      return (100 - this.canaryIngress.canary_weight).toString();
    },
    canaryWeight() {
      return this.canaryIngress.canary_weight.toString();
    },
  },
  methods: {
    changeCanary(weight) {
      this.$emit('change', weight);
    },
    changeStable(weight) {
      this.$emit('change', 100 - weight);
    },
  },
};
</script>
<template>
  <section class="gl-display-flex gl-bg-white gl-m-3">
    <div class="gl-display-flex gl-flex-direction-column">
      <label for="stable" :class="$options.css.label" class="gl-rounded-top-left-base">{{
        $options.translations.stableLabel
      }}</label>
      <gl-dropdown
        id="stable"
        :text="stableWeight"
        class="gl-w-full"
        toggle-class="gl-rounded-top-left-none! gl-rounded-top-right-none! gl-rounded-bottom-right-none!"
      >
        <gl-dropdown-item
          v-for="option in $options.ingressOptions"
          :key="option"
          @click="changeStable(option)"
          >{{ option }}</gl-dropdown-item
        >
      </gl-dropdown>
    </div>
    <div class="gl-display-flex gl-display-flex gl-flex-direction-column">
      <label :class="$options.css.label" class="gl-rounded-top-right-base">{{
        $options.translations.canaryLabel
      }}</label>
      <gl-dropdown
        :text="canaryWeight"
        toggle-class="gl-rounded-top-left-none! gl-rounded-top-right-none! gl-rounded-bottom-left-none! gl-border-l-none!"
      >
        <gl-dropdown-item
          v-for="option in $options.ingressOptions"
          :key="option"
          @click="changeCanary(option)"
          >{{ option }}</gl-dropdown-item
        >
      </gl-dropdown>
    </div>
  </section>
</template>
