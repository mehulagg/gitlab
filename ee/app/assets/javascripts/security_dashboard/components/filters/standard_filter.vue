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
    // Number of options that must exist for the search box to show.
    searchBoxShowThreshold: {
      type: Number,
      required: false,
      default: 20,
    },
    loading: {
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
    options() {
      return this.filter.options;
    },
    selectedSet() {
      return new Set(this.selectedOptions);
    },
    isNoOptionsSelected() {
      return this.selectedOptions?.length <= 0;
    },
    selectedOptionsOrAll() {
      return this.selectedOptions?.length ? this.selectedOptions : [this.filter.allOption];
    },
    queryObject() {
      // This is the object used to update the querystring.
      return { [this.filter.id]: this.selectedOptionsOrAll.map((x) => x.id) };
    },
    filterObject() {
      // This is the object used by the GraphQL query.
      return { [this.filter.id]: this.selectedOptions?.map((x) => x.id) };
    },
    filteredOptions() {
      return this.options.filter((option) =>
        option.name.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    },
    routeQuery() {
      return this.$route?.query[this.filter.id];
    },
    routeQueryIds() {
      const ids = this.routeQuery || [];
      const idArray = Array.isArray(ids) ? ids : [ids];

      return idArray.includes(this.filter.allOption.id) ? [] : idArray;
    },
    routeQueryOptions() {
      // There was no saved querystring for this filter, return the default options.
      if (this.routeQuery === undefined) {
        return this.filter.defaultOptions;
      }

      return this.options.filter((x) => this.routeQueryIds.includes(x.id));
    },
    showSearchBox() {
      return this.options.length >= this.searchBoxShowThreshold;
    },
  },
  watch: {
    selectedOptions() {
      this.$emit('filter-changed', this.filterObject);
    },
    loading: {
      immediate: true,
      handler() {
        if (this.loading) {
          this.$emit('filter-changed', { [this.filter.id]: this.routeQueryIds || [] });
          window.removeEventListener('popstate', this.setSelectedOptionsFromQuerystring);
        } else {
          this.setSelectedOptionsFromQuerystring();
          window.addEventListener('popstate', this.setSelectedOptionsFromQuerystring);
        }
      },
    },
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
      // To avoid a console error, don't update the querystring if it's the same as the current one.
      if (!this.$router || isEqual(this.routeQueryIds, this.queryObject[this.filter.id])) {
        return;
      }

      const query = { query: { ...this.$route?.query, ...this.queryObject } };
      this.$router.push(query);
    },
    isSelected(option) {
      return this.selectedSet.has(option);
    },
    setSelectedOptionsFromQuerystring() {
      this.selectedOptions = this.routeQueryOptions;
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
    :loading="loading"
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
