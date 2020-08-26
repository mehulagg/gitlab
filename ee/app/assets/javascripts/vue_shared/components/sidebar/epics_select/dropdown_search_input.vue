<script>
import { debounce } from 'lodash';
import { GlDeprecatedButton, GlIcon } from '@gitlab/ui';
import autofocusonshow from '~/vue_shared/directives/autofocusonshow';

export default {
  components: {
    GlDeprecatedButton,
    GlIcon,
  },
  directives: {
    autofocusonshow,
  },
  data() {
    return {
      query: '',
    };
  },
  methods: {
    handleKeyUp: debounce(function debouncedKeyUp() {
      this.$emit('onSearchInput', this.query);
    }, 300),
    handleInputClear() {
      this.query = '';
      this.handleKeyUp();
    },
  },

  emits: ['onSearchInput'],
};
</script>

<template>
  <div :class="{ 'has-value': query }" class="dropdown-input">
    <input
      v-model.trim="query"
      v-autofocusonshow
      :placeholder="__('Search')"
      autocomplete="off"
      class="dropdown-input-field"
      type="search"
      @keyup="handleKeyUp"
    />
    <gl-icon v-show="!query" name="search" />
    <gl-deprecated-button
      variant="link"
      class="fa fa-times dropdown-input-clear js-dropdown-input-clear"
      data-hidden="true"
      @click.stop="handleInputClear"
    />
  </div>
</template>
