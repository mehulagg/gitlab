<script>
import { GlDropdown, GlDropdownItem, GlDropdownSectionHeader, GlSearchBoxByType } from '@gitlab/ui';
import { debounce } from 'lodash';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import { BRANCH_REF_TYPE, TAG_REF_TYPE } from '../constants';
import formatRefs from '../utils/format_refs';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlDropdownSectionHeader,
    GlSearchBoxByType,
  },
  props: {
    refsEndpoint: {
      type: String,
      required: true,
    },
    value: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      isLoading: false,
      searchTerm: '',
      branches: [],
      tags: [],
    };
  },
  computed: {
    lowerCasedSearchTerm() {
      return this.searchTerm.toLowerCase();
    },
    refShortName() {
      return this.value.shortName;
    },
    hasTags() {
      return this.tags.length > 0;
    },
  },
  watch: {
    searchTerm() {
      this.debouncedLoadRefs();
    },
  },
  methods: {
    loadRefs() {
      this.isLoading = true;

      axios
        .get(this.refsEndpoint, {
          params: {
            ref: this.value.fullName,
            search: this.lowerCasedSearchTerm ? this.lowerCasedSearchTerm : undefined,
          },
        })
        .then(({ data }) => {
          const { Branches = [], Tags = [] } = data;
          this.branches = formatRefs(Branches, BRANCH_REF_TYPE);
          this.tags = formatRefs(Tags, TAG_REF_TYPE);
        })
        .catch(() => {
          createFlash({ message: __('Something went wrong on our end. Please try again.') });
        })
        .finally(() => {
          this.isLoading = false;
        });
    },
    debouncedLoadRefs: debounce(function debouncedLoadRefs() {
      this.loadRefs();
    }, 250),
    setRefSelected(ref) {
      this.$emit('input', ref);
    },
    isSelected(ref) {
      return ref.fullName === this.value.fullName;
    },
  },
};
</script>
<template>
  <gl-dropdown :text="refShortName" block @show.once="loadRefs">
    <gl-search-box-by-type
      v-model.trim="searchTerm"
      :is-loading="isLoading"
      :placeholder="__('Search refs')"
    />
    <gl-dropdown-section-header>{{ __('Branches') }}</gl-dropdown-section-header>
    <gl-dropdown-item
      v-for="branch in branches"
      :key="branch.fullName"
      class="gl-font-monospace"
      is-check-item
      :is-checked="isSelected(branch)"
      @click="setRefSelected(branch)"
    >
      {{ branch.shortName }}
    </gl-dropdown-item>
    <gl-dropdown-section-header v-if="hasTags">{{ __('Tags') }}</gl-dropdown-section-header>
    <gl-dropdown-item
      v-for="tag in tags"
      :key="tag.fullName"
      class="gl-font-monospace"
      is-check-item
      :is-checked="isSelected(tag)"
      @click="setRefSelected(tag)"
    >
      {{ tag.shortName }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
