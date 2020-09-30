<script>
/* eslint-disable vue/no-v-html */
import { mountComponent } from '../lib/helpers';
import { FILTER_TYPES, FILTER_DATA_BY_TYPE } from '../constants';
import DropdownFilter from './dropdown_filter.vue';

export default {
  props: {
    html: {
      type: String,
      required: false,
      default: '',
    },
  },
  mounted() {
    mountComponent(
      this,
      DropdownFilter,
      { filterData: FILTER_DATA_BY_TYPE[FILTER_TYPES.STATE] },
      '#js-search-filter-by-state',
    );
    if (gon.features?.searchFilterByConfidential) {
      mountComponent(
        this,
        DropdownFilter,
        { filterData: FILTER_DATA_BY_TYPE[FILTER_TYPES.CONFIDENTIAL] },
        '#js-search-filter-by-confidential',
      );
    }
  },
};
</script>

<template>
  <section v-html="html"></section>
</template>
