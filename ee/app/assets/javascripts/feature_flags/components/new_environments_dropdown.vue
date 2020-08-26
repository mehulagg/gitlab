<script>
import {
  GlNewDropdown,
  GlNewDropdownDivider,
  GlNewDropdownItem,
  GlIcon,
  GlLoadingIcon,
  GlSearchBoxByType,
} from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { __, sprintf } from '~/locale';
import { deprecatedCreateFlash as createFlash } from '~/flash';

export default {
  components: {
    GlNewDropdown,
    GlNewDropdownDivider,
    GlNewDropdownItem,
    GlSearchBoxByType,
    GlIcon,
    GlLoadingIcon,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      environmentSearch: '',
      results: [],
      filter: '',
      isLoading: false,
    };
  },
  translations: {
    addEnvironmentsLabel: __('Add environment'),
    noResultsLabel: __('No matching results'),
  },
  computed: {
    createEnvironmentLabel() {
      return sprintf(__('Create %{environment}'), { environment: this.filter });
    },
  },
  methods: {
    addEnvironment(newEnvironment) {
      this.$emit('add', newEnvironment);
      this.environmentSearch = '';
      this.filter = '';
    },
    fetchEnvironments() {
      this.filter = this.environmentSearch;
      this.isLoading = true;

      axios
        .get(this.endpoint, { params: { query: this.filter } })
        .then(({ data }) => {
          this.results = data;
        })
        .catch(() => {
          createFlash(__('Something went wrong on our end. Please try again.'));
        })
        .finally(() => {
          this.isLoading = false;
        });
    },
  },

  emits: ['add'],
};
</script>
<template>
  <gl-new-dropdown class="js-new-environments-dropdown">
    <template #button-content>
      <span class="d-md-none mr-1">
        {{ $options.translations.addEnvironmentsLabel }}
      </span>
      <gl-icon class="d-none d-md-inline-flex" name="plus" />
    </template>
    <gl-search-box-by-type
      v-model.trim="environmentSearch"
      class="m-2"
      @input="fetchEnvironments"
    />
    <gl-loading-icon v-if="isLoading" />
    <gl-new-dropdown-item
      v-for="environment in results"
      v-else-if="results.length"
      :key="environment"
      @click="addEnvironment(environment)"
    >
      {{ environment }}
    </gl-new-dropdown-item>
    <template v-else-if="filter.length">
      <span ref="noResults" class="text-secondary p-2">
        {{ $options.translations.noMatchingResults }}
      </span>
      <gl-new-dropdown-divider />
      <gl-new-dropdown-item @click="addEnvironment(filter)">
        {{ createEnvironmentLabel }}
      </gl-new-dropdown-item>
    </template>
  </gl-new-dropdown>
</template>
