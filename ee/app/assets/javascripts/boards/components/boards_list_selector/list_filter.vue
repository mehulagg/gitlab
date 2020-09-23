<script>
import { GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
  },
  data() {
    return {
      query: '',
    };
  },
  methods: {
    handleInputChange() {
      this.$emit('onSearchInput', this.query);
    },
    handleInputClear() {
      this.query = '';
      this.handleInputChange();
    },
  },
};
</script>

<template>
  <div :class="{ 'has-value': !!query }" class="dropdown-input">
    <input
      v-model.trim="query"
      :placeholder="__('Search')"
      type="search"
      class="dropdown-input-field"
      @keyup="handleInputChange"
    />
    <i class="fa fa-search dropdown-input-search" aria-hidden="true" data-hidden="true"></i>
    <gl-icon
      name="close"
      class="dropdown-input-clear"
      aria-hidden="true"
      @click="handleInputClear"
    />
  </div>
</template>
