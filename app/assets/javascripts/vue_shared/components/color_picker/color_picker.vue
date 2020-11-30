<script>
/**
 * Renders a color picker input with preset colors to choose from
 *
 * @example
 * <color-picker :label="__('Background color')" />
 */
import { GlFormInput, GlLink, GlSprintf, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'ColorPicker',
  components: {
    GlFormInput,
    GlLink,
    GlSprintf,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    label: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      selectedColor: '',
    };
  },
  computed: {
    suggestedColors() {
      const colorsMap = gon.suggested_label_colors;
      return Object.keys(colorsMap).map(color => ({ [color]: colorsMap[color] }));
    },
    previewColor() {
      if (this.selectedColor.length) {
        return { backgroundColor: this.selectedColor };
      }

      return {};
    },
  },
  methods: {
    getColorCode(color) {
      return Object.keys(color).pop();
    },
    getColorName(color) {
      return Object.values(color).pop();
    },
    handleColorChange(color) {
      if (color.indexOf('#') === 0) {
        this.selectedColor = color;
      } else {
        this.selectedColor = '';
      }
    },
  },
  i18n: {
    description: s__(
      '%{descriptionStart}Choose any color.%{descriptionEnd}%{descriptionStart}Or you can choose one of the suggested colors below%{descriptionEnd}',
    ),
  },
};
</script>

<template>
  <div>
    <label v-if="label" for="color-picker" class="label-bold">{{ label }}</label>
    <div class="gl-display-flex gl-mb-3">
      <div
        class="gl-relative gl-align-center gl-justify-center gl-w-7 gl-overflow-hidden gl-border-1 gl-border-solid gl-border-gray-100 gl-rounded-base gl-rounded-top-right-none gl-rounded-bottom-right-none gl-bg-gray-10"
      >
        <span
          class="gl-w-full gl-h-full gl-absolute gl-top-0 gl-left-0"
          :style="previewColor"
          tabindex="-1"
          aria-hidden="true"
        ></span>
        <gl-form-input
          v-model="selectedColor"
          type="color"
          class="gl-absolute gl-top-0 gl-left-0 gl-h-full! gl-p-0! gl-m-0!"
          style="opacity: 0"
          tabindex="-1"
          aria-hidden="true"
        />
      </div>

      <gl-form-input
        id="color-picker"
        type="text"
        class="gl-align-center gl-justify-center gl-border-1 gl-border-gray-100  gl-rounded-base gl-rounded-top-left-none gl-rounded-bottom-left-none"
        :value="selectedColor"
        @input="handleColorChange"
      />
    </div>

    <small class="gl-display-block gl-font-base gl-line-height-normal gl-text-gray-700 gl-mb-3">
      <gl-sprintf :message="this.$options.i18n.description">
        <template #description="{ content }">
          <span class="gl-display-block">{{ content }}</span>
        </template>
      </gl-sprintf>
    </small>

    <div class="gl-mb-3">
      <gl-link
        v-for="(color, index) in suggestedColors"
        :key="index"
        v-gl-tooltip:tooltipcontainer
        :title="getColorName(color)"
        :style="{ backgroundColor: getColorCode(color) }"
        class="gl-rounded-base gl-w-7 gl-h-7 gl-display-inline-block gl-mr-3 gl-mb-3 gl-text-decoration-none"
        @click.prevent="handleColorChange(getColorCode(color))"
      />
    </div>
  </div>
</template>
