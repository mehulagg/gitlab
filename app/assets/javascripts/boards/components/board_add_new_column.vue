<script>
import {
  GlButton,
  GlFormGroup,
  GlFormRadio,
  GlFormRadioGroup,
  GlLabel,
  GlSearchBoxByType,
  GlSkeletonLoader,
  GlTooltipDirective as GlTooltip,
} from '@gitlab/ui';
import { mapActions, mapGetters } from 'vuex';
import { __ } from '~/locale';
import { isScopedLabel } from '~/lib/utils/common_utils';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import boardsStore from '../stores/boards_store';

export default {
  inject: ['scopedLabelsAvailable'],
  i18n: {
    add: __('Add'),
    cancel: __('Cancel'),
    formDescription: __('A label list displays all issues with the selected label.'),
    labelsError: __('Unable to load labels'),
    newLabelList: __('New label list'),
    noLabelSelected: __('No label selected'),
    searchPlaceholder: __('Search labels'),
    selectLabel: __('Select label'),
    selected: __('Selected'),
  },
  components: {
    GlButton,
    GlFormGroup,
    GlFormRadio,
    GlFormRadioGroup,
    GlLabel,
    GlSearchBoxByType,
    GlSkeletonLoader,
  },
  directives: {
    GlTooltip,
  },
  data() {
    return {
      labels: [],
      loading: false,
      searchTerm: '',
      selectedLabelId: null,
    };
  },
  computed: {
    ...mapGetters(['getListByLabelId', 'shouldUseGraphQL']),
    selectedLabel() {
      return this.labels.find(({ id }) => id === this.selectedLabelId);
    },
  },
  created() {
    this.filterLabels();
  },
  methods: {
    ...mapActions(['createList', 'fetchLabels', 'highlightList', 'setAddColumnFormVisibility']),
    getListByLabel(label) {
      if (this.shouldUseGraphQL) {
        return this.getListByLabelId(label);
      }
      return boardsStore.findListByLabelId(label.id);
    },
    columnExists(label) {
      return Boolean(this.getListByLabel(label));
    },
    highlight(listId) {
      if (this.shouldUseGraphQL) {
        this.highlightList(listId);
      } else {
        const list = boardsStore.state.lists.find(({ id }) => id === listId);
        list.highlighted = true;
        setTimeout(() => {
          list.highlighted = false;
        }, 4000);
      }
    },
    addList() {
      if (!this.selectedLabelId) {
        return;
      }

      const label = this.selectedLabel();

      if (!label) {
        return;
      }

      if (this.columnExists({ id: this.selectedLabelId })) {
        const listId = this.getListByLabel(label).id;
        this.highlight(listId);
        this.setAddColumnFormVisibility(false);
        return;
      }

      if (this.shouldUseGraphQL) {
        this.createList({ labelId: this.selectedLabelId })
          .then((list) => {
            this.setAddColumnFormVisibility(false);
            this.highlight(list.id);
          })
          .catch((e) => {
            // todo: create list failed, reopen form and show error
            throw e;
          });
      } else {
        boardsStore.new({
          title: label.title,
          position: boardsStore.state.lists.length - 2,
          list_type: 'label',
          label: {
            id: label.id,
            title: label.title,
            color: label.color,
          },
        });

        this.highlight(boardsStore.findListByLabelId(label.id).id);
        this.setAddColumnFormVisibility(false);
      }
    },

    filterLabels() {
      this.loading = true;
      this.fetchLabels(this.searchTerm)
        .then((labels) => {
          if (this.shouldUseGraphQL) {
            this.labels = labels;
          } else {
            this.labels = labels.map((label) => {
              return {
                ...label,
                id: getIdFromGraphQLId(label.id),
              };
            });
          }
        })
        .catch((e) => {
          this.labels = [];
          this.error = this.$options.i18n.labelsError;
          throw e;
        })
        .finally(() => {
          this.loading = false;
        });
    },

    showScopedLabels(label) {
      return this.scopedLabelsAvailable && isScopedLabel(label);
    },
  },
};
</script>

<template>
  <div
    class="board-add-new-list board gl-display-inline-block gl-h-full gl-px-3 gl-mb-7 gl-vertical-align-top gl-white-space-normal gl-flex-shrink-0"
    data-qa-selector="board_add_new_list"
  >
    <div
      class="board-inner gl-display-flex gl-flex-direction-column gl-relative gl-h-full gl-rounded-base gl-bg-white"
    >
      <h3
        class="gl-font-base gl-px-5 gl-py-5 gl-m-0 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100"
        data-testid="board-add-column-form-title"
      >
        {{ $options.i18n.newLabelList }}
      </h3>

      <div class="gl-display-flex gl-flex-direction-column gl-h-full gl-overflow-hidden">
        <!-- selectbox is here in EE -->

        <p class="gl-m-5">{{ $options.i18n.formDescription }}</p>

        <div class="gl-px-5 gl-pb-4">
          <label class="gl-mb-2">{{ $options.i18n.selected }}</label>
          <div>
            <gl-label
              v-if="selectedLabel"
              v-gl-tooltip
              :title="selectedLabel.title"
              :description="selectedLabel.description"
              :background-color="selectedLabel.color"
              :scoped="showScopedLabels(selectedLabel)"
            />
            <div v-else class="gl-text-gray-500">{{ $options.i18n.noLabelSelected }}</div>
          </div>
        </div>

        <gl-form-group
          class="gl-mx-5"
          :label="$options.i18n.selectLabel"
          label-for="board-available-labels"
        >
          <gl-search-box-by-type
            id="board-available-labels"
            v-model.trim="searchTerm"
            debounce="250"
            :placeholder="$options.i18n.searchPlaceholder"
            @input="filterLabels"
          />
        </gl-form-group>

        <div v-if="loading" class="gl-m-5">
          <gl-skeleton-loader :width="500" :height="172">
            <rect width="480" height="20" x="10" y="15" rx="4" />
            <rect width="380" height="20" x="10" y="50" rx="4" />
            <rect width="430" height="20" x="10" y="85" rx="4" />
          </gl-skeleton-loader>
        </div>

        <gl-form-radio-group v-else v-model="selectedLabelId" class="gl-overflow-y-auto gl-px-5">
          <label
            v-for="label in labels"
            :key="label.id"
            class="gl-display-flex gl-flex-align-items-center gl-mb-5 gl-font-weight-normal"
          >
            <gl-form-radio :value="label.id" class="gl-mb-0 gl-mr-3" />
            <span
              class="dropdown-label-box gl-top-0"
              :style="{
                backgroundColor: label.color,
              }"
            ></span>
            <span>{{ label.title }}</span>
          </label>
        </gl-form-radio-group>
      </div>

      <div
        class="gl-display-flex gl-p-3 gl-border-t-1 gl-border-t-solid gl-border-gray-100 gl-bg-gray-10"
      >
        <gl-button class="gl-ml-auto gl-mr-3" @click="setAddColumnFormVisibility(false)">{{
          $options.i18n.cancel
        }}</gl-button>
        <gl-button
          :disabled="!selectedLabelId"
          variant="success"
          class="gl-mr-4"
          @click="addList"
          >{{ $options.i18n.add }}</gl-button
        >
      </div>
    </div>
  </div>
</template>
