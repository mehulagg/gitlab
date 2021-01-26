<script>
import { GlTokenSelector } from '@gitlab/ui';
import { isEmpty } from 'lodash';

export default {
  name: 'CommaSeparatedListTokenSelector',
  hiddenInput: null,
  components: { GlTokenSelector },
  props: {
    hiddenInputId: {
      type: String,
      required: true,
    },
    ariaLabelledby: {
      type: String,
      required: true,
    },
    placeholder: {
      type: String,
      required: false,
      default: null,
    },
    regexValidator: {
      type: RegExp,
      required: false,
      default: null,
    },
    disallowedValues: {
      type: Array,
      required: false,
      default: () => [],
    },
    regexErrorMessage: {
      type: String,
      required: false,
      default: '',
    },
    disallowedValueErrorMessage: {
      type: String,
      required: false,
      default: '',
    },
    customErrorMessage: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      selectedTokens: [],
      textInputValue: '',
      hideErrorMessage: true,
    };
  },
  computed: {
    tokenIsValid() {
      return this.computedErrorMessage === '';
    },
    computedErrorMessage() {
      if (this.regexValidator !== null && this.textInputValue.match(this.regexValidator) === null) {
        return this.regexErrorMessage;
      }

      if (!isEmpty(this.disallowedValues) && this.disallowedValues.includes(this.textInputValue)) {
        return this.disallowedValueErrorMessage;
      }

      return this.customErrorMessage;
    },
  },
  watch: {
    selectedTokens(newValue) {
      this.$options.hiddenInput.value = newValue.map((token) => token.name).join(',');

      // Dispatch `input` event so form submit button becomes active
      this.$options.hiddenInput.dispatchEvent(
        new Event('input', {
          bubbles: true,
          cancelable: true,
        }),
      );
    },
  },
  mounted() {
    const hiddenInput = document.getElementById(this.hiddenInputId);
    this.$options.hiddenInput = hiddenInput;

    if (hiddenInput.value === '') {
      return;
    }

    this.selectedTokens = hiddenInput.value.split(/,\s*/).map((token, index) => ({
      id: index,
      name: token,
    }));
  },
  methods: {
    handleEnter(event) {
      if (this.textInputValue !== '' && !this.tokenIsValid) {
        this.hideErrorMessage = false;

        // Trigger a focus event on the token selector to explicitly open the dropdown and display the error message
        this.$nextTick(() => {
          this.$refs.tokenSelector.$el
            .querySelector('input[type="text"]')
            .dispatchEvent(new Event('focus'));
        });
      }

      // Prevent form from submitting when adding a token
      if (event.target.value !== '') {
        event.preventDefault();
      }
    },
    handleTextInput(value) {
      this.hideErrorMessage = true;
      this.textInputValue = value;
      this.$emit('text-input', value);
    },
    handleBlur() {
      this.hideErrorMessage = true;
    },
  },
};
</script>

<template>
  <gl-token-selector
    ref="tokenSelector"
    v-model="selectedTokens"
    container-class="gl-h-auto!"
    :allow-user-defined-tokens="tokenIsValid"
    :hide-dropdown-with-no-items="hideErrorMessage"
    :aria-labelledby="ariaLabelledby"
    :placeholder="placeholder"
    @keydown.enter="handleEnter"
    @text-input="handleTextInput"
    @blur="handleBlur"
  >
    <template #user-defined-token-content="{ inputText }">
      <slot name="user-defined-token-content" :input-text="inputText"></slot>
    </template>
    <template #no-results-content>
      <span class="gl-text-red-500">{{ computedErrorMessage }}</span>
    </template>
  </gl-token-selector>
</template>
