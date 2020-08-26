<script>
import { GlNewDropdown, GlNewDropdownHeader, GlNewDropdownItem } from '@gitlab/ui';
import { s__ } from '~/locale';

const SORTING_TITLE = s__('SortOptions|Sort by:');
const SORTING_OPTIONS = [
  {
    key: 'created_desc',
    text: s__('SortOptions|Last created'),
  },
  {
    key: 'created_asc',
    text: s__('SortOptions|Oldest created'),
  },
];

export default {
  components: {
    GlNewDropdown,
    GlNewDropdownHeader,
    GlNewDropdownItem,
  },
  props: {
    sortBy: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    selectedOption() {
      return SORTING_OPTIONS.find(option => option.key === this.sortBy) || SORTING_OPTIONS[0];
    },
  },
  methods: {
    onItemClick(option) {
      this.$emit('selected', option);
    },
    isChecked(key) {
      return key === this.selectedOption.key;
    },
  },

  SORTING_TITLE,
  SORTING_OPTIONS,
  emits: ['selected'],
};
</script>

<template>
  <div>
    <gl-new-dropdown :text="selectedOption.text" class="w-100 flex-column flex-lg-row form-group">
      <gl-new-dropdown-header> {{ $options.SORTING_TITLE }}</gl-new-dropdown-header>
      <gl-new-dropdown-item
        v-for="option in $options.SORTING_OPTIONS"
        :key="option.key"
        :is-check-item="true"
        :is-checked="isChecked(option.key)"
        @click="onItemClick(option.key)"
      >
        {{ option.text }}
      </gl-new-dropdown-item>
    </gl-new-dropdown>
  </div>
</template>
