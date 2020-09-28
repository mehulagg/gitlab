<script>
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    value: {
      type: Boolean,
      required: true,
    },
    helpPath: {
      type: String,
      required: false,
      default: '',
    },
    isDisabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    tooltipTitle() {
      return this.isDisabled ? __('Required in this project.') : null;
    },
    tooltipFocusable() {
      return this.isDisabled ? '0' : null;
    },
  },
};
</script>

<template>
  <div class="inline">
    <label
      v-gl-tooltip
      :class="{ 'gl-text-gray-400': isDisabled }"
      :tabindex="tooltipFocusable"
      data-testid="squashLabel"
      :title="tooltipTitle"
    >
      <input
        :checked="value"
        :disabled="isDisabled"
        type="checkbox"
        name="squash"
        class="qa-squash-checkbox js-squash-checkbox"
        @change="$emit('input', $event.target.checked)"
      />
      {{ __('Squash commits') }}
    </label>
    <a
      v-if="helpPath"
      v-gl-tooltip
      :href="helpPath"
      :title="__('What is squashing?')"
      target="_blank"
      rel="noopener noreferrer nofollow"
    >
      <gl-icon name="question" />
      <span class="sr-only">
        {{ __('What is squashing?') }}
      </span>
    </a>
  </div>
</template>
