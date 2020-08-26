<script>
import { dateInWords } from '~/lib/utils/datetime_utility';
import { __ } from '~/locale';
import Cell from './cell.vue';

export default {
  name: 'DateCell',
  components: {
    Cell,
  },
  props: {
    title: {
      type: String,
      required: false,
      default: null,
    },
    value: {
      type: [String, Date],
      required: false,
      default: null,
    },
    dateNow: {
      type: Date,
      required: false,
      default() {
        return new Date();
      },
    },
    isExpirable: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    dateInWordsValue() {
      return dateInWords(this.dateValue);
    },
    dateValue() {
      return new Date(this.value);
    },
    isExpired() {
      return this.isExpirable && this.dateValue < this.dateNow;
    },
    valueClass() {
      return { 'text-danger': this.isExpired };
    },
    fallbackValue() {
      return this.isExpirable ? this.dateInWords || __('Never') : this.dateInWords;
    },
  },

  emits: [],
};
</script>

<template>
  <cell :title="title" :value="fallbackValue">
    <div v-if="value" slot="value" :class="valueClass">
      {{ dateInWordsValue }}
      <span v-if="isExpired"> - {{ __('Expired') }} </span>
    </div>
  </cell>
</template>
