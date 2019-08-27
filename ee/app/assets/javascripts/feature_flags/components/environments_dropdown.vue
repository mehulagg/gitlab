<script>
import _ from 'lodash-es';
import { GlLoadingIcon, GlButton } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import createFlash from '~/flash';

/**
 * Creates a searchable input for environments.
 *
 * When given a value, it will render it as selected value
 * Otherwise it will render a placeholder for the search
 * input.
 *
 * When the user types, it will trigger an event to allow
 * for API queries outside of the component.
 *
 * When results are returned, it renders a selectable
 * list with the suggestions
 *
 * When no results are returned, it will render a
 * button with a `Create` label. When clicked, it will
 * emit an event to allow for the creation of a new
 * record.
 *
 */

export default {
  name: 'EnvironmentsSearchableInput',
  components: {
    GlButton,
    GlLoadingIcon,
    Icon,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    value: {
      type: String,
      required: false,
      default: '',
    },
    placeholder: {
      type: String,
      required: false,
      default: __('Search an environment spec'),
    },
    createButtonLabel: {
      type: String,
      required: false,
      default: __('Create'),
    },
    disabled: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      filter: this.value || '',
      results: [],
      showSuggestions: false,
      isLoading: false,
    };
  },
  computed: {
    /**
     * Creates a label with the value of the filter
     * @returns {String}
     */
    composedCreateButtonLabel() {
      return `${this.createButtonLabel} ${this.filter}`;
    },
    /**
     * Create button is available when
     * - loading is false, filter is set and no results are available
     * @returns Boolean
     */
    shouldRenderCreateButton() {
      return !_.isEmpty(this.filter) && !this.isLoading && !this.results.length;
    },
  },
  watch: {
    value(newVal) {
      this.filter = newVal;
    },
  },
  methods: {
    /**
     * On each input event, it updates the filter value and fetches the
     * list of environments based on the value typed.
     *
     * Since we need to update the input value both with the value provided by the parent
     * and the value typed by the user, we can't use v-model.
     */
    fetchEnvironments(evt) {
      this.filter = evt.target.value;

      this.isLoading = true;
      this.openSuggestions();

      return axios
        .get(this.endpoint, { params: { query: this.filter } })
        .then(({ data }) => {
          this.results = data;
          this.isLoading = false;
        })
        .catch(() => {
          this.isLoading = false;
          this.closeSuggestions();

          createFlash(__('Something went wrong on our end. Please try again.'));
        });
    },
    /**
     * Opens the list of suggestions
     */
    openSuggestions() {
      this.showSuggestions = true;
    },
    /**
     * Closes the list of suggestions and cleans the results
     */
    closeSuggestions() {
      this.showSuggestions = false;
      this.results = [];
    },
    /**
     * On click, it will:
     *  1. clear the input value
     *  2. close the list of suggestions
     *  3. emit an event
     */
    clearInput() {
      this.filter = '';
      this.closeSuggestions();
      this.$emit('clearInput');
    },
    /**
     * When the user selects a value from the list of suggestions
     *
     * It emits an event with the selected value
     * Clears the filter
     * and closes the list of suggestions
     *
     * @param {String} selected
     */
    selectEnvironment(selected) {
      this.$emit('selectEnvironment', selected);

      this.filter = '';
      this.closeSuggestions();
    },

    /**
     * When the user clicks the create button
     * it emits an event with the filter value
     * Clears the input and closes the list of suggestions.
     */
    createClicked() {
      this.$emit('createClicked', this.filter);
      this.filter = '';
      this.closeSuggestions();
    },
  },
};
</script>
<template>
  <div>
    <div class="dropdown position-relative">
      <icon name="search" class="seach-icon-input" />

      <input
        type="text"
        class="js-env-input form-control pl-4"
        :aria-label="placeholder"
        :value="filter"
        :placeholder="placeholder"
        :disabled="disabled"
        @input="fetchEnvironments"
      />

      <gl-button
        v-if="!disabled"
        class="js-clear-search-input btn-transparent clear-search-input position-right-0"
        @click="clearInput"
      >
        <icon name="clear" :aria-label="__('Clear input')" />
      </gl-button>

      <div
        v-if="showSuggestions"
        class="dropdown-menu d-block dropdown-menu-selectable dropdown-menu-full-width"
      >
        <div class="dropdown-content">
          <gl-loading-icon v-if="isLoading" />

          <ul v-else-if="results.length">
            <li v-for="(result, i) in results" :key="i">
              <gl-button class="btn-transparent" @click="selectEnvironment(result)">{{
                result
              }}</gl-button>
            </li>
          </ul>
          <div v-else-if="!results.length" class="text-secondary p-2">
            {{ __('No matching results') }}
          </div>

          <div v-if="shouldRenderCreateButton" class="dropdown-footer">
            <gl-button class="js-create-button btn-blank dropdown-item" @click="createClicked">{{
              composedCreateButtonLabel
            }}</gl-button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
