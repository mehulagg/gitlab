<script>
/* eslint-disable vue/no-v-html */
import { mountComponent } from '../lib/helpers';
import TestComponent from './test_component.vue';

export default {
  props: {
    html: {
      type: String,
      required: false,
      default: '',
    },
  },
  mounted() {
    mountComponent(this, TestComponent, '#search-page-title');
  },
};
</script>

<template>
  <section v-html="html"></section>
</template>
