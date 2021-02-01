<script>
import { GlFormGroup, GlDropdown, GlDropdownItem, GlFormText, GlLink, GlSprintf } from '@gitlab/ui';
import { CUSTOM_VALUE_MESSAGE } from './constants';

export default {
  components: {
    GlFormGroup,
    GlDropdown,
    GlDropdownItem,
    GlFormText,
    GlLink,
    GlSprintf,
  },
  // The DynamicFields component v-binds the configuration entity to this
  // component. This ensures extraneous keys/values are not added as attributes
  // to the underlying GlFormGroup.
  inheritAttrs: false,
  model: {
    prop: 'value',
    event: 'input',
  },
  props: {
    value: {
      type: String,
      required: true,
    },
    defaultValue: {
      type: String,
      required: false,
      default: null,
    },
    field: {
      type: String,
      required: true,
    },
    label: {
      type: String,
      required: true,
    },
    defaultText: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    options: {
      type: Array,
      required: true,
      validator: (options) =>
        options.every(({ value, text }) => ![value, text].includes(undefined)),
    },
  },
  computed: {
    showCustomValueMessage() {
      return this.defaultValue !== null && !this.disabled && this.value !== this.defaultValue;
    },
    text() {
      return this.options.find((option) => option.value === this.value)?.text || this.defaultText;
    },
  },
  methods: {
    resetToDefaultValue() {
      this.$emit('input', this.defaultValue);
    },
    handleInput(option) {
      this.$emit('input', option.value);
    },
  },
  i18n: {
    CUSTOM_VALUE_MESSAGE,
  },
};
</script>

<template>
  <gl-form-group :label-for="field">
    <template #label>
      {{ label }}
      <gl-form-text class="gl-mt-3">{{ description }}</gl-form-text>
    </template>

    <gl-dropdown :id="field" :text="text" :disabled="disabled">
      <gl-dropdown-item v-for="option in options" :key="option.value" @click="handleInput(option)">
        {{ option.text }}
      </gl-dropdown-item>
    </gl-dropdown>

    <template v-if="showCustomValueMessage" #description>
      <gl-sprintf :message="$options.i18n.CUSTOM_VALUE_MESSAGE">
        <template #anchor="{ content }">
          <gl-link @click="resetToDefaultValue" v-text="content" />
        </template>
      </gl-sprintf>
    </template>
  </gl-form-group>
</template>
