<script>
import { GlLabel, GlButton, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlButton,
    GlLabel,
  },
  props: {
    framework: {
      type: Object,
      required: true,
    },
    loading: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    isScoped() {
      return this.framework.name.includes('::');
    },
  },
  i18n: {
    deleteFramework: s__('ComplianceFrameworks|Delete framework'),
  },
};
</script>
<template>
  <div
    class="gl-display-flex gl-align-items-center gl-justify-content-space-between gl-inset-border-1-gray-100 gl-px-5 gl-p-6 gl-mb-4"
  >
    <div class="gl-w-quarter gl-mr-3 gl-flex-shrink-0">
      <gl-label
        target="#"
        :background-color="framework.color"
        :title="framework.name"
        :scoped="isScoped"
        :disabled="loading"
      />
    </div>
    <p class="gl-w-full gl-m-0!" data-testid="compliance-framework-description">
      {{ framework.description }}
    </p>
    <div>
      <gl-button
        v-gl-tooltip="$options.i18n.deleteFramework"
        :loading="loading"
        :disabled="loading"
        :aria-label="$options.i18n.deleteFramework"
        data-testid="compliance-framework-delete-button"
        icon="remove"
        category="tertiary"
        @click="$emit('delete', framework)"
      />
    </div>
  </div>
</template>
