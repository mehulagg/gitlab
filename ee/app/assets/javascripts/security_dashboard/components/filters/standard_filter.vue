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
  },
  data() {
    return {
      searchTerm: '',
      selectedOptions: this.filter.defaultOptions || [],
      shouldUpdateRouteQuery: true,
    };
  },
  computed: {
    selectedSet() {
      return new Set(this.selectedOptions);
    },
    selectedOptionsOrAll() {
      const { selectedOptions, filter } = this;
      if (filter.allOption) {
        return selectedOptions.length ? selectedOptions : [filter.allOption];
      }

      return selectedOptions;
    },
    queryObject() {
      return { [this.filter.id]: this.selectedOptionsOrAll.map(x => x.id) };
    },
    filterObject() {
      return { [this.filter.id]: this.selectedOptions.map(x => x.id) };
    },
    filteredOptions() {
      return this.filter.options.filter(option =>
        option.name.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    },
    routeQuery() {
      const keys = this.$route.query[this.filter.id] || [];
      return Array.isArray(keys) ? keys : [keys];
    },
    routeQueryOptions() {
      return this.filter.options.filter(x => this.routeQuery.includes(x.id));
    },
  },
  watch: {
    selectedOptions() {
      this.$emit('filter-changed', this.filterObject);

      if (this.shouldUpdateRouteQuery) {
        this.updateRouteQuery();
      }
    },
  },
  created() {
    // Select the options based on the querystring.
    if (this.routeQueryOptions.length) {
      // SET SELECTED OPTIONS BUT DON'T UPDATE QUERYSTRING
      this.selectedOptions = this.routeQueryOptions;
    }

    // WHEN USER CLICKS FORWARD/BACK BUTTON, SET SELECTED OPTIONS BUT DON'T UPDATE QUERYSTRING
    window.addEventListener('popstate', () => {
      this.shouldUpdateRouteQuery = false;
      this.selectedOptions = this.routeQueryOptions;

      this.$nextTick(() => {
        this.shouldUpdateRouteQuery = true;
      });
    });
  },
  methods: {
    toggleOption(option) {
      // Toggle the option's existence in the array.
      this.selectedOptions = xor(this.selectedOptions, [option]);
    },
    deselectAllOptions() {
      this.selectedOptions = [];
    },
    updateRouteQuery() {
      const query = { query: { ...this.$route.query, ...this.queryObject } };

      if (!isEqual(this.routeQuery, Object.values(this.queryObject))) {
        console.log('ROUTE IS NOT EQUAL, UPDATING ROUTE!', query);
        this.$router.push(query);
      } else {
        console.log('ROUTE IS EQUAL, DOING NOTHING!');
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
    :show-search-box="filter.options.length >= 20"
  >
    <filter-item
      v-if="filter.allOption && !searchTerm.length"
      :is-checked="selectedOptions.length <= 0"
      :text="filter.allOption.name"
      @click="deselectAllOptions"
    />
    <filter-item
      v-for="option in filteredOptions"
      :key="option.id"
      :is-checked="isSelected(option)"
      :text="option.name"
      @click="toggleOption(option)"
    />
  </filter-body>
</template>
