<script>
import { mapState, mapGetters, mapActions } from 'vuex';
import {
  GlLoadingIcon,
  GlDropdown,
  GlDropdownDivider,
  GlDropdownItem,
  GlSearchBoxByType,
} from '@gitlab/ui';
import { debounce } from 'lodash';
import { noneEpic } from 'ee/vue_shared/constants';
import { __ } from '~/locale';
import createStore from './store';
import DropdownValue from './dropdown_value.vue';
import DropdownValueCollapsed from './dropdown_value_collapsed.vue';
import { DropdownVariant } from './constants';

export default {
  noneEpic,
  store: createStore(),
  components: {
    GlLoadingIcon,
    GlDropdown,
    GlDropdownDivider,
    GlDropdownItem,
    GlSearchBoxByType,
    DropdownValue,
    DropdownValueCollapsed,
  },
  props: {
    groupId: {
      type: Number,
      required: true,
    },
    issueId: {
      type: Number,
      required: false,
      default: 0,
    },
    epicIssueId: {
      type: Number,
      required: false,
      default: 0,
    },
    canEdit: {
      type: Boolean,
      required: true,
    },
    blockTitle: {
      type: String,
      required: false,
      default: __('Epic'),
    },
    initialEpic: {
      type: Object,
      required: true,
    },
    initialEpicLoading: {
      type: Boolean,
      required: true,
    },
    variant: {
      type: String,
      required: false,
      default: DropdownVariant.Sidebar,
    },
    showHeader: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      isDropdownShowing: false,
      search: '',
    };
  },
  computed: {
    ...mapState([
      'epicSelectInProgress',
      'epicsFetchInProgress',
      'selectedEpic',
      'searchQuery',
      'selectedEpicIssueId',
    ]),
    ...mapGetters(['isDropdownVariantSidebar', 'isDropdownVariantStandalone', 'groupEpics']),
    dropdownSelectInProgress() {
      return this.initialEpicLoading || this.epicSelectInProgress;
    },
    dropdownButtonTextClass() {
      return { 'is-default': this.isDropdownVariantStandalone };
    },
    dropDownTitle() {
      return this.selectedEpic.title ?? __('Select epic');
    },
    dropdownClass() {
      return this.isDropdownShowing ? 'dropdown-menu-epics show' : 'gl-display-none';
    },
    epicListValid() {
      return this.groupEpics.length > 0 && !this.epicsFetchInProgress && !this.epicSelectInProgress;
    },
    epicListNotValid() {
      return (
        this.groupEpics.length === 0 && !this.epicsFetchInProgress && !this.epicSelectInProgress
      );
    },
  },
  watch: {
    /**
     * When Issue is created from Boards
     * Issue ID is updated post-render
     * so we need to watch it to update in state
     */
    issueId() {
      this.setIssueId(this.issueId);
    },
    /**
     * When Issues are selected within Boards
     * `initialEpic` gets updated to reflect
     * underlying selection.
     */
    initialEpic() {
      this.setSelectedEpic(this.initialEpic);
      this.setSelectedEpicIssueId(this.epicIssueId);
    },
    /**
     * Initial Epic is loaded via separate Sidebar store
     * So we need to watch for updates before updating local store.
     */
    initialEpicLoading() {
      this.setSelectedEpic(this.initialEpic);
      this.setSelectedEpicIssueId(this.epicIssueId);
    },
    /**
     * Check if `searchQuery` presence has yielded any matching
     * epics, if not, dispatch `fetchEpics` with search query.
     */
    searchQuery(value) {
      if (value) {
        this.fetchEpics(this.searchQuery);
      } else {
        this.fetchEpics();
      }
    },
    search: debounce(function debouncedEpicSearch() {
      this.setSearchQuery(this.search);
    }, 250),
  },
  mounted() {
    this.setInitialData({
      variant: this.variant,
      groupId: this.groupId,
      issueId: this.issueId,
      selectedEpic: this.initialEpic,
      selectedEpicIssueId: this.epicIssueId,
    });
  },
  methods: {
    ...mapActions([
      'setInitialData',
      'setIssueId',
      'setSearchQuery',
      'setSelectedEpic',
      'setSelectedEpicIssueId',
      'fetchEpics',
      'assignIssueToEpic',
      'removeIssueFromEpic',
    ]),
    handleItemSelect(epic) {
      if (
        this.selectedEpicIssueId &&
        epic.id === this.$options.noneEpic.id &&
        epic.title === this.$options.noneEpic.title
      ) {
        this.removeIssueFromEpic(this.selectedEpic);
      } else if (this.issueId) {
        this.assignIssueToEpic(epic);
      } else {
        this.$emit('onEpicSelect', epic);
      }
    },
    hideDropdown() {
      this.isDropdownShowing = this.isDropdownVariantStandalone;
    },
    toggleFormDropdown() {
      this.isDropdownShowing = !this.isDropdownShowing;
      const { dropdown } = this.$refs.dropdown.$refs;
      if (dropdown && this.isDropdownShowing) {
        dropdown.show();
        this.fetchEpics();
      }
    },
  },
};
</script>

<template>
  <div class="js-epic-block" :class="{ 'block epic': isDropdownVariantSidebar }">
    <div
      v-if="canEdit || isDropdownVariantStandalone"
      class="hide-collapsed epic-dropdown-container"
    >
      <p
        v-if="isDropdownVariantSidebar"
        class="title gl-display-flex gl-justify-content-space-between"
      >
        {{ __('Epic') }}
        <a
          v-if="canEdit"
          ref="editButton"
          class="btn-link"
          href="#"
          @click="toggleFormDropdown"
          @keydown.esc="hideDropdown"
        >
          {{ __('Edit') }}
        </a>
      </p>

      <gl-dropdown
        ref="dropdown"
        :text="dropDownTitle"
        class="gl-w-full"
        :class="dropdownClass"
        toggle-class="dropdown-menu-toggle"
        @keydown.esc.native="hideDropdown"
        @hide="hideDropdown"
      >
        <p
          v-if="isDropdownVariantSidebar || showHeader"
          class="gl-new-dropdown-header-top"
          data-testid="epic-dropdown-header"
        >
          {{ __('Assign Epic') }}
        </p>
        <gl-search-box-by-type v-model.trim="search" :placeholder="__('Search epics')" />
        <div class="dropdown-content dropdown-body">
          <template v-if="epicListValid">
            <gl-dropdown-item
              :active="!selectedEpic"
              active-class="is-active"
              @click="handleItemSelect($options.noneEpic)"
            >
              {{ __('No Epic') }}
            </gl-dropdown-item>
            <gl-dropdown-divider />
            <gl-dropdown-item
              v-for="epic in groupEpics"
              :key="epic.id"
              :active="selectedEpic.id === epic.id"
              active-class="is-active"
              :is-check-item="true"
              :is-checked="selectedEpic.id === epic.id"
              @click="handleItemSelect(epic)"
              >{{ epic.title }}</gl-dropdown-item
            >
          </template>
          <p v-else-if="epicListNotValid" class="gl-mx-5 gl-my-4">
            {{ __('No Matching Results') }}
          </p>
          <gl-loading-icon v-else />
        </div>
      </gl-dropdown>
    </div>

    <div v-if="isDropdownVariantSidebar && !isDropdownShowing">
      <dropdown-value-collapsed :epic="selectedEpic" />
      <dropdown-value :epic="selectedEpic">
        <slot></slot>
      </dropdown-value>
    </div>
  </div>
</template>
