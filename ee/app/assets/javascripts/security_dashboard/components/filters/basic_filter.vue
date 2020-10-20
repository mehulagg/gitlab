<script>
import FilterOption from './filter_option.vue';
import FilterBody from './filter_body.vue';

export default {
  components: {
    FilterOption,
    FilterBody,
  },
  props: {
    filter: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      filterTerm: '',
      selectedOptions: this.getSelectedOptions(),
    };
  },
  computed: {
    selectedCount() {
      return Object.keys(this.selectedOptions).length;
    },
    firstSelectedOption() {
      if (this.selectedCount > 0) {
        return Object.values(this.selectedOptions)[0].name;
      }

      return this.filter.allOption.name;
    },
    filteredOptions() {
      return this.filter.options.filter(option =>
        option.name.toLowerCase().includes(this.filterTerm.toLowerCase()),
      );
    },
  },
  watch: {
    selectedOptions() {
      const filter = { [this.filter.id]: Object.keys(this.selectedOptions) };
      this.$router.replace({ query: { ...this.$route.query, ...filter } });
      this.$emit('filter-changed', filter);
    },
  },
  methods: {
    getSelectedOptions() {
      let keys = this.$route.query[this.filter.id];
      keys = Array.isArray(keys) ? keys : [keys];
      const selected = {};

      // Convert the querystring keys to the selected options object.
      keys.forEach(key => {
        const option = this.filter.options.find(x => x.id === key);
        if (option) {
          selected[option.id] = option;
        }
      });

      return selected;
    },
    toggleFilter(option) {
      if (this.selectedOptions[option.id]) {
        this.$delete(this.selectedOptions, option.id);
      } else {
        this.$set(this.selectedOptions, option.id, option);
      }
    },
    deselectAllOptions() {
      this.selectedOptions = {};
    },
    isSelected(option) {
      return Boolean(this.selectedOptions[option.id]);
    },
    updateFilterTerm(newFilterTerm) {
      this.filterTerm = newFilterTerm;
    },
  },
};
</script>

<template>
  <filter-body
    v-model="filterTerm"
    :name="filter.name"
    :selected-count="selectedCount"
    :selected-option="firstSelectedOption"
    :show-search-box="filter.options.length >= 4"
    @filter-changed="updateFilterTerm"
  >
    <filter-option
      v-if="filter.allOption && !filterTerm.length"
      :display-name="filter.allOption.name"
      :is-selected="!selectedCount"
      @click="deselectAllOptions"
    />

    <filter-option
      v-for="option in filteredOptions"
      :key="option.id"
      :display-name="option.name"
      :is-selected="isSelected(option)"
      @click="toggleFilter(option)"
    />
  </filter-body>
</template>
