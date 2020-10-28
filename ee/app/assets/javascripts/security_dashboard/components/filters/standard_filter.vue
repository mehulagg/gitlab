<script>
import FilterBody from './filter_body.vue';
import FilterItem from './filter_item.vue';

export default {
  components: {
    FilterBody,
    FilterItem,
  },
  props: {
    filter: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      searchTerm: '',
    };
  },
  computed: {
    selection() {
      return this.filter.selection;
    },
    filteredOptions() {
      return this.filter.options.filter(option =>
        option.name.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    },
    selectedOptionsNames() {
      return Array.from(this.selection).map(id => this.filter.options.find(x => x.id === id).name);
    },
  },
  methods: {
    clickFilter(option) {
      this.$emit('setFilter', { filterId: this.filter.id, optionId: option.id });
    },
    isSelected(option) {
      return this.selection.has(option.id);
    },
  },
};
</script>

<template>
  <filter-body
    v-model.trim="searchTerm"
    :name="filter.name"
    :selected-options="selectedOptionsNames"
    :show-search-box="filter.options.length >= 20"
  >
    <filter-item
      v-for="option in filteredOptions"
      :key="option.id"
      :is-checked="isSelected(option)"
      :text="option.name"
      @click="clickFilter(option)"
    />
  </filter-body>
</template>
