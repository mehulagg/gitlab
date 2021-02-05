<script>
import { GlTooltipDirective, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
};
</script>

<template>
  <div class="d-flex align-items-center">
    <div class="square s24 d-flex-center mr-2 text-tertiary">
      <gl-icon name="folder-o" :size="16" data-testid="folder-icon" />
    </div>
    <span>{{ __('Private group(s)') }}</span>
    <gl-icon
      v-gl-tooltip
      :title="__('One or more groups that you don\'t have access to.')"
      class="ml-1 gl-text-gray-500"
      name="question-o"
      :size="16"
      data-testid="help-icon"
    />
  </div>
</template>
