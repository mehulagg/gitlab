<script>
import { mapState, mapGetters, mapActions } from 'vuex';

import $ from 'jquery';
import { GlLoadingIcon } from '@gitlab/ui';

import { noneEpic } from 'ee/vue_shared/constants';
import { __ } from '~/locale';

import createStore from './store';

import DropdownTitle from './dropdown_title.vue';
import DropdownValue from './dropdown_value.vue';
import DropdownValueCollapsed from './dropdown_value_collapsed.vue';

import DropdownButton from './dropdown_button.vue';
import DropdownHeader from './dropdown_header.vue';
import DropdownSearchInput from './dropdown_search_input.vue';
import DropdownContents from './dropdown_contents.vue';

import { DropdownVariant } from './constants';

export default {
  store: createStore(),
  components: {
    GlLoadingIcon,
    DropdownTitle,
    DropdownValue,
    DropdownValueCollapsed,
    DropdownButton,
    DropdownHeader,
    DropdownSearchInput,
    DropdownContents,
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
      showDropdown: this.variant === DropdownVariant.Standalone,
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
  },
  mounted() {
    this.setInitialData({
      variant: this.variant,
      groupId: this.groupId,
      issueId: this.issueId,
      selectedEpic: this.initialEpic,
      selectedEpicIssueId: this.epicIssueId,
    });
    $(this.$refs.dropdown).on('shown.bs.dropdown', () => this.fetchEpics());
    $(this.$refs.dropdown).on('hidden.bs.dropdown', this.handleDropdownHidden);
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
    handleEditClick() {
      this.showDropdown = true;

      // Wait for component to render dropdown container
      this.$nextTick(() => {
        // We're not calling $.dropdown('show') to open
        // dropdown and instead triggerring click on button
        // so that clicking outside can make dropdown close
        // additionally, this approach requires event trigger
        // to be deferred so that it doesn't close
        setTimeout(() => {
          $(this.$refs.dropdownButton.$el).trigger('click');
        });
      });
    },
    handleDropdownHidden() {
      this.showDropdown = this.isDropdownVariantStandalone;
    },
    handleItemSelect(epic) {
      if (this.selectedEpicIssueId && epic.id === noneEpic.id && epic.title === noneEpic.title) {
        this.removeIssueFromEpic(this.selectedEpic);
      } else if (this.issueId) {
        this.assignIssueToEpic(epic);
      } else {
        this.$emit('epicSelect', epic);
      }
    },
  },
};
</script>

<template>
  <div class="js-epic-block" :class="{ 'block epic': isDropdownVariantSidebar }">
    <dropdown-value-collapsed v-if="isDropdownVariantSidebar" :epic="selectedEpic" />
    <dropdown-title
      v-if="isDropdownVariantSidebar"
      :can-edit="canEdit"
      :block-title="blockTitle"
      :is-loading="dropdownSelectInProgress"
      @onClickEdit="handleEditClick"
    />
    <dropdown-value v-if="isDropdownVariantSidebar" v-show="!showDropdown" :epic="selectedEpic">
      <slot></slot>
    </dropdown-value>
    <div
      v-if="canEdit || isDropdownVariantStandalone"
      v-show="showDropdown"
      class="epic-dropdown-container"
    >
      <div ref="dropdown" class="dropdown">
        <dropdown-button
          ref="dropdownButton"
          :selected-epic-title="selectedEpic.title"
          :toggle-text-class="dropdownButtonTextClass"
        />
        <div class="dropdown-menu dropdown-select dropdown-menu-epics dropdown-menu-selectable">
          <dropdown-header v-if="isDropdownVariantSidebar || showHeader" />
          <dropdown-search-input @onSearchInput="setSearchQuery" />
          <dropdown-contents
            v-if="!epicsFetchInProgress"
            :epics="groupEpics"
            :selected-epic="selectedEpic"
            @onItemSelect="handleItemSelect"
          />
          <gl-loading-icon
            v-if="epicsFetchInProgress"
            class="dropdown-contents-loading"
            size="md"
          />
        </div>
      </div>
    </div>
  </div>
</template>
