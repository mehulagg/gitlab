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
import { mapActions, mapGetters, mapState } from 'vuex';
import boardsStore from '~/boards/stores/boards_store';
import { isScopedLabel } from '~/lib/utils/common_utils';
import { __ } from '~/locale';

export default {
  i18n: {
    add: __('Add'),
    cancel: __('Cancel'),
    formDescription: __('A label list displays all issues with the selected label.'),
    newLabelList: __('New label list'),
    noLabelSelected: __('No label selected'),
    searchPlaceholder: __('Search milestones'),
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
  inject: ['scopedLabelsAvailable'],
  data() {
    return {
      searchTerm: '',
      selectedId: null,
      columnType: 'milestone',
    };
  },
  computed: {
    ...mapState(['labels', 'labelsLoading', 'milestones', 'milestonesLoading']),
    ...mapGetters(['getListByTypeId', 'shouldUseGraphQL']),
    selectedLabel() {
      return this.labels.find(({ id }) => id === this.selectedId);
    },
    selectedMilestone() {
      if (this.columnType !== 'milestone') {
        return null;
      }
      return this.milestones.find(({ id }) => id === this.selectedId);
    },
    selectedItem() {
      if (!this.selectedId) {
        return null;
      }
      if (this.columnType === 'label') {
        return this.selectedLabel;
      }
      if (this.columnType === 'milestone') {
        return this.selectedMilestone;
      }
      return null;
    },
    columnForSelected() {
      if (!this.columnType) {
        return false;
      }

      // keyname looks like `labelId`
      const key = `${this.columnType}Id`;
      return this.getListByTypeId({
        [key]: this.selectedId,
      });
    },
    loading() {
      if (this.columnType === 'label') {
        return this.labelsLoading;
      }
      if (this.columnType === 'milestone') {
        return this.milestonesLoading;
      }
      return false;
    },
  },
  created() {
    this.filterItems();
  },
  methods: {
    ...mapActions([
      'createList',
      'fetchLabels',
      'highlightList',
      'setAddColumnFormVisibility',
      'fetchMilestones',
    ]),
    highlight(listId) {
      if (this.shouldUseGraphQL) {
        this.highlightList(listId);
      } else {
        const list = boardsStore.state.lists.find(({ id }) => id === listId);
        list.highlighted = true;
        setTimeout(() => {
          list.highlighted = false;
        }, 2000);
      }
    },
    addList() {
      if (!this.selectedId) {
        return;
      }

      if (!this.selectedItem) {
        return;
      }

      this.setAddColumnFormVisibility(false);

      if (this.columnForSelected) {
        const listId = this.columnForSelected.id;
        this.highlight(listId);
        return;
      }

      if (this.shouldUseGraphQL) {
        // eslint-disable-next-line @gitlab/require-i18n-strings
        this.createList({ [`${this.columnType}Id`]: this.selectedId });
      } else {
        if (this.columnType !== 'label') {
          throw new Error('non-label lists not supported without graphql');
        }

        const label = this.selectedLabel;

        if (!label) {
          return;
        }

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
      }
    },

    filterItems() {
      switch (this.columnType) {
        case 'milestone':
          this.fetchMilestones(this.searchTerm);
          break;
        case 'label':
        default:
          this.fetchLabels(this.searchTerm);
      }
    },

    showScopedLabels(label) {
      return this.scopedLabelsAvailable && isScopedLabel(label);
    },
  },
};
</script>

<template>
  <div
    class="board-add-new-list board gl-display-inline-block gl-h-full gl-px-3 gl-vertical-align-top gl-white-space-normal gl-flex-shrink-0"
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
            <div v-else-if="selectedMilestone" class="gl-text-truncate">
              {{ selectedMilestone.title }}
            </div>
            <div v-else class="gl-text-gray-500">{{ $options.i18n.noLabelSelected }}</div>
          </div>
        </div>

        <gl-form-group
          class="gl-mx-5 gl-mb-3"
          :label="$options.i18n.selectLabel"
          label-for="board-available-milestones"
        >
          <gl-search-box-by-type
            id="board-available-milestones"
            v-model.trim="searchTerm"
            debounce="250"
            :placeholder="$options.i18n.searchPlaceholder"
            @input="filterItems"
          />
        </gl-form-group>

        <div v-if="loading" class="gl-m-5">
          <gl-skeleton-loader :width="500" :height="172">
            <rect width="480" height="20" x="10" y="15" rx="4" />
            <rect width="380" height="20" x="10" y="50" rx="4" />
            <rect width="430" height="20" x="10" y="85" rx="4" />
          </gl-skeleton-loader>
        </div>

        <gl-form-radio-group v-else v-model="selectedId" class="gl-overflow-y-auto gl-px-5 gl-pt-3">
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
          <label
            v-for="milestone in milestones"
            :key="milestone.id"
            class="gl-display-flex gl-flex-align-items-center gl-mb-5 gl-font-weight-normal"
          >
            <gl-form-radio :value="milestone.id" class="gl-mb-0 gl-mr-3" />
            <span>{{ milestone.title }}</span>
          </label>
        </gl-form-radio-group>
      </div>

      <div
        class="gl-display-flex gl-p-3 gl-border-t-1 gl-border-t-solid gl-border-gray-100 gl-bg-gray-10"
      >
        <gl-button
          data-testid="cancelAddNewColumn"
          class="gl-ml-auto gl-mr-3"
          @click="setAddColumnFormVisibility(false)"
          >{{ $options.i18n.cancel }}</gl-button
        >
        <gl-button
          data-testid="addNewColumnButton"
          :disabled="!selectedId"
          variant="success"
          class="gl-mr-4"
          @click="addList"
          >{{ $options.i18n.add }}</gl-button
        >
      </div>
    </div>
  </div>
</template>
