<script>
import { debounce } from 'lodash';
import { GlButton, GlIcon } from '@gitlab/ui';
import autofocusonshow from '~/vue_shared/directives/autofocusonshow';

export default {
  components: {
    GlButton,
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
    <gl-button
      variant="link"
      icon="close"
      class="dropdown-input-clear js-dropdown-input-clear"
      data-hidden="true"
      @click.stop="handleInputClear"
    />
  </div>
</template>
