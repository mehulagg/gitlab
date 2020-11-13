<script>
import { debounce } from 'lodash';
import { mapActions } from 'vuex';
import { GlIcon } from '@gitlab/ui';
import eventHub from '../event_hub';
import frequentItemsMixin from './frequent_items_mixin';
import Tracking from '~/tracking';

export default {
  components: {
    GlIcon,
  },
  mixins: [frequentItemsMixin],
  data() {
    return {
      searchQuery: '',
    };
  },
  computed: {
    translations() {
      return this.getTranslations(['searchInputPlaceholder']);
    },
  },
  watch: {
    searchQuery: debounce(function debounceSearchQuery() {
      const trackEvent = 'type_search_query';
      const trackCategory = undefined; // will be default set in event method

      Tracking.event(trackCategory, trackEvent, {
        label: 'projects_dropdown_frequent_items_search_input',
      });

      this.setSearchQuery(this.searchQuery);
    }, 500),
  },
  mounted() {
    eventHub.$on(`${this.namespace}-dropdownOpen`, this.setFocus);
  },
  beforeDestroy() {
    eventHub.$off(`${this.namespace}-dropdownOpen`, this.setFocus);
  },
  methods: {
    ...mapActions(['setSearchQuery']),
    setFocus() {
      this.$refs.search.focus();
    },
  },
};
</script>

<template>
  <div class="search-input-container d-none d-sm-block">
    <input
      ref="search"
      v-model="searchQuery"
      :placeholder="translations.searchInputPlaceholder"
      type="search"
      class="form-control"
    />
    <gl-icon v-if="!searchQuery" name="search" class="search-icon" />
  </div>
</template>
