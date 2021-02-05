<script>
import { isEqual, xor } from 'lodash';
import FilterBody from './filter_body.vue';
import FilterItem from './filter_item.vue';

export default {
  components: { FilterBody, FilterItem },
  props: {
    filter: {
      type: Object,
      required: true,
    },
    showSearchBox: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      searchTerm: '',
      selectedOptions: undefined,
    };
  },
  computed: {
    selectedSet() {
      return new Set(this.selectedOptions);
    },
    isNoOptionsSelected() {
      return this.selectedOptions.length <= 0;
    },
    selectedOptionsOrAll() {
      return this.selectedOptions.length ? this.selectedOptions : [this.filter.allOption];
    },
    queryObject() {
      // This is the object used to update the querystring.
      return { [this.filter.id]: this.selectedOptionsOrAll.map((x) => x.id) };
    },
    filterObject() {
      // This is the object used by the GraphQL query.
      return { [this.filter.id]: this.selectedOptions.map((x) => x.id) };
    },
    filteredOptions() {
      return this.filter.options.filter((option) =>
        option.name.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    },
    routeQueryIds() {
      const ids = this.$route?.query[this.filter.id] || [];
      return Array.isArray(ids) ? ids : [ids];
    },
    routeQueryOptions() {
      const options = this.filter.options.filter((x) => this.routeQueryIds.includes(x.id));
      const hasAllId = this.routeQueryIds.includes(this.filter.allOption.id);

      if (options.length && !hasAllId) {
        return options;
      }

      return hasAllId ? [] : this.filter.defaultOptions;
    },
  },
  watch: {
    selectedOptions() {
      this.$emit('filter-changed', this.filterObject);
    },
  },
  created() {
    this.selectedOptions = this.routeQueryOptions;
    // When the user clicks the forward/back browser buttons, update the selected options.
    window.addEventListener('popstate', () => {
      this.selectedOptions = this.routeQueryOptions;
    });
  },
  methods: {
    toggleOption(option) {
      // Toggle the option's existence in the array.
      this.selectedOptions = xor(this.selectedOptions, [option]);
      this.updateRouteQuery();
    },
    deselectAllOptions() {
      this.selectedOptions = [];
      this.updateRouteQuery();
    },
    updateRouteQuery() {
      if (!this.$router) {
        return;
      }

      const query = { query: { ...this.$route?.query, ...this.queryObject } };
      // To avoid a console error, don't update the querystring if it's the same as the current one.
      if (!isEqual(this.routeQueryIds, this.queryObject[this.filter.id])) {
        this.$router.push(query);
      }
    },
    isSelected(option) {
      return this.selectedSet.has(option);
    },
  },
};
</script>

<template>
  <filter-body
    v-model.trim="searchTerm"
    :name="filter.name"
    :selected-options="selectedOptionsOrAll"
    :show-search-box="showSearchBox"
  >
    <filter-item
      v-if="filter.allOption && !searchTerm.length"
      :is-checked="isNoOptionsSelected"
      :text="filter.allOption.name"
      data-testid="allOption"
      @click="deselectAllOptions"
    />
    <filter-item
      v-for="option in filteredOptions"
      :key="option.id"
      :is-checked="isSelected(option)"
      :text="option.name"
      data-testid="filterOption"
      @click="toggleOption(option)"
    />
  </filter-body>
</template>
