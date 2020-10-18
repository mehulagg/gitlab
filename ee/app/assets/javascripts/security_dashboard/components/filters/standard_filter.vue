<script>
import FilterBody from './filter_body.vue';
import FilterItem from './filter_item.vue';
import FilterMixin from './filter_mixin';

export default {
  components: {
    FilterBody,
    FilterItem,
  },
  mixins: [FilterMixin],
  props: {
    filter: {
      type: Object,
      required: true,
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
      :is-checked="selectedCount <= 0"
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
