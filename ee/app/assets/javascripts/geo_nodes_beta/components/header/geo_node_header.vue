<script>
import { GlButton, GlBadge } from '@gitlab/ui';

export default {
  name: 'GeoNodeHeader',
  components: {
    GlButton,
    GlBadge,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
    collapsed: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    chevronIcon() {
      return this.collapsed ? 'chevron-right' : 'chevron-down';
    },
  },
};
</script>

<template>
  <div
    class="gl-display-grid geo-node-header-grid-columns gl-bg-gray-10 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100 gl-border-t-1 gl-border-t-solid gl-border-t-gray-100 gl-py-3 gl-px-5"
  >
    <div class="gl-display-flex gl-align-items-center">
      <gl-button
        class="gl-mr-3 gl-p-0!"
        category="tertiary"
        variant="confirm"
        :icon="chevronIcon"
        @click="$emit('collapse')"
      />
      <div
        class="gl-display-flex gl-flex-direction-column gl-md-flex-direction-row gl-md-align-items-center gl-flex-fill-1"
      >
        <div class="gl-display-flex gl-align-items-center gl-flex-fill-1">
          <gl-badge v-if="node.current" variant="info" class="gl-mr-2">{{
            __('Current')
          }}</gl-badge>
          <h4 class="gl-font-lg">{{ node.name }}</h4>
        </div>
        <div class="gl-display-flex gl-align-items-center gl-flex-fill-2">
          <span>{{ s__('Geo|Health Status') }}</span>
          <span class="gl-ml-2">{{ __('Last Updated') }}</span>
        </div>
      </div>
    </div>
    <div class="gl-display-flex gl-align-items-center gl-justify-content-end">
      <span>{{ __('Actions') }}</span>
    </div>
  </div>
</template>
