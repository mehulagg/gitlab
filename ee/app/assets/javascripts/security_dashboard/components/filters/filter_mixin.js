import { xor, isEqual } from 'lodash';

export default {
  data() {
    return {
      searchTerm: '',
      selectedOptions: [],
    };
  },
  computed: {
    selectedSet() {
      return new Set(this.selectedOptions);
    },
    selectedCount() {
      return this.selectedOptions.length;
    },
    selectedOptionsOrAll() {
      const { selectedCount, selectedOptions, filter } = this;
      return selectedCount ? selectedOptions : [filter.allOption];
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
  },
  watch: {
    selectedOptions() {
      this.$emit('filter-changed', this.filterObject);
    },
  },
  created() {
    // Select the options based on the querystring.
    this.selectedOptions = this.routeQuery.length
      ? this.filter.options.filter(x => this.routeQuery.includes(x.id))
      : this.filter.defaultOptions || [];
    this.updateRouteQuery(true);

    window.addEventListener('popstate', () => {
      this.selectedOptions = this.filter.options.filter(x => this.routeQuery.includes(x.id));
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
    updateRouteQuery(replaceRoute) {
      const method = replaceRoute ? this.$router.replace : this.$router.push;
      const query = { query: { ...this.$route.query, ...this.queryObject } };

      if (!isEqual(this.routeQuery, this.queryObject[this.filter.id])) {
        method.call(this.$router, query);
      }
    },
    isSelected(option) {
      return this.selectedSet.has(option);
    },
  },
};
