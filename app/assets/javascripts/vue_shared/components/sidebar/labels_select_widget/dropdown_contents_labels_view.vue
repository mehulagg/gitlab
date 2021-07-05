<script>
import { GlLoadingIcon, GlSearchBoxByType, GlLink } from '@gitlab/ui';
import fuzzaldrinPlus from 'fuzzaldrin-plus';
import { mapState, mapGetters, mapActions } from 'vuex';

import { UP_KEY_CODE, DOWN_KEY_CODE, ENTER_KEY_CODE, ESC_KEY_CODE } from '~/lib/utils/keycodes';

import LabelItem from './label_item.vue';
import projectLabelsQuery from './graphql/project_labels.query.graphql';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

export default {
  components: {
    GlLoadingIcon,
    GlSearchBoxByType,
    GlLink,
    LabelItem,
  },
  inject: ['projectPath'],
  data() {
    return {
      searchKey: '',
      currentHighlightItem: -1,
    };
  },
  apollo: {
    labels: {
      query: projectLabelsQuery,
      variables() {
        return {
          fullPath: this.projectPath,
          searchTerm: this.searchKey,
        };
      },
      skip() {
        return this.searchKey.length === 1;
      },
      debounce: 250,
      update: (data) => data.workspace.labels.nodes,
    },
  },
  computed: {
    ...mapState([
      'allowLabelCreate',
      'allowMultiselect',
      'labelsManagePath',
      'labelsListTitle',
      'footerCreateLabelTitle',
      'footerManageLabelTitle',
    ]),
    ...mapGetters(['selectedLabelsList', 'isDropdownVariantSidebar', 'isDropdownVariantEmbedded']),
    labelsFetchInProgress() {
      return this.$apollo.queries.labels.loading;
    },
    visibleLabels() {
      if (this.searchKey) {
        return fuzzaldrinPlus.filter(this.labels, this.searchKey, {
          key: ['title'],
        });
      }
      return this.labels;
    },
    showNoMatchingResultsMessage() {
      return Boolean(this.searchKey) && this.visibleLabels.length === 0;
    },
  },
  watch: {
    searchKey(value) {
      // When there is search string present
      // and there are matching results,
      // highlight first item by default.
      if (value && this.visibleLabels.length) {
        this.currentHighlightItem = 0;
      }
    },
  },
  methods: {
    ...mapActions([
      'toggleDropdownContents',
      'toggleDropdownContentsCreateView',
      'fetchLabels',
      'receiveLabelsSuccess',
      'updateSelectedLabels',
    ]),
    isLabelSelected(label) {
      return this.selectedLabelsList.includes(getIdFromGraphQLId(label.id));
    },
    /**
     * This method scrolls item from dropdown into
     * the view if it is off the viewable area of the
     * container.
     */
    scrollIntoViewIfNeeded() {
      const highlightedLabel = this.$refs.labelsListContainer.querySelector('.is-focused');

      if (highlightedLabel) {
        const container = this.$refs.labelsListContainer.getBoundingClientRect();
        const label = highlightedLabel.getBoundingClientRect();

        if (label.bottom > container.bottom) {
          this.$refs.labelsListContainer.scrollTop += label.bottom - container.bottom;
        } else if (label.top < container.top) {
          this.$refs.labelsListContainer.scrollTop -= container.top - label.top;
        }
      }
    },
    handleComponentAppear() {
      // We can avoid putting `catch` block here
      // as failure is handled within actions.js already.
      return this.fetchLabels().then(() => {
        this.$refs.searchInput.focusInput();
      });
    },
    handleCreateLabelClick() {
      this.receiveLabelsSuccess([]);
      this.toggleDropdownContentsCreateView();
    },
    /**
     * This method enables keyboard navigation support for
     * the dropdown.
     */
    handleKeyDown(e) {
      if (e.keyCode === UP_KEY_CODE && this.currentHighlightItem > 0) {
        this.currentHighlightItem -= 1;
      } else if (
        e.keyCode === DOWN_KEY_CODE &&
        this.currentHighlightItem < this.visibleLabels.length - 1
      ) {
        this.currentHighlightItem += 1;
      } else if (e.keyCode === ENTER_KEY_CODE && this.currentHighlightItem > -1) {
        this.updateSelectedLabels([this.visibleLabels[this.currentHighlightItem]]);
        this.searchKey = '';
      } else if (e.keyCode === ESC_KEY_CODE) {
        this.toggleDropdownContents();
      }

      if (e.keyCode !== ESC_KEY_CODE) {
        // Scroll the list only after highlighting
        // styles are rendered completely.
        this.$nextTick(() => {
          this.scrollIntoViewIfNeeded();
        });
      }
    },
    handleLabelClick(label) {
      this.updateSelectedLabels([label]);
      if (!this.allowMultiselect) this.toggleDropdownContents();
    },
  },
};
</script>

<template>
  <div class="labels-select-contents-list js-labels-list" @keydown="handleKeyDown">
    <div class="dropdown-input" @click.stop="() => {}">
      <gl-search-box-by-type
        ref="searchInput"
        v-model="searchKey"
        :disabled="labelsFetchInProgress"
        data-qa-selector="dropdown_input_field"
      />
    </div>
    <div ref="labelsListContainer" class="dropdown-content" data-testid="dropdown-content">
      <gl-loading-icon
        v-if="labelsFetchInProgress"
        class="labels-fetch-loading gl-align-items-center w-100 h-100"
        size="md"
      />
      <ul v-else class="list-unstyled gl-mb-0 gl-word-break-word">
        <label-item
          v-for="(label, index) in visibleLabels"
          :key="label.id"
          :label="label"
          :is-label-set="isLabelSelected(label)"
          :highlight="index === currentHighlightItem"
          @clickLabel="handleLabelClick(label)"
        />
        <li v-show="showNoMatchingResultsMessage" class="gl-p-3 gl-text-center">
          {{ __('No matching results') }}
        </li>
      </ul>
    </div>
    <div
      v-if="isDropdownVariantSidebar || isDropdownVariantEmbedded"
      class="dropdown-footer"
      data-testid="dropdown-footer"
    >
      <ul class="list-unstyled">
        <li v-if="allowLabelCreate">
          <gl-link
            class="gl-display-flex w-100 flex-row text-break-word label-item"
            @click="handleCreateLabelClick"
          >
            {{ footerCreateLabelTitle }}
          </gl-link>
        </li>
        <li>
          <gl-link
            :href="labelsManagePath"
            class="gl-display-flex flex-row text-break-word label-item"
          >
            {{ footerManageLabelTitle }}
          </gl-link>
        </li>
      </ul>
    </div>
  </div>
</template>
