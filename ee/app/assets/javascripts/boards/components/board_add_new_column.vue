<script>
import {
  GlFormGroup,
  GlFormRadio,
  GlFormRadioGroup,
  GlFormSelect,
  GlLabel,
  GlTooltipDirective as GlTooltip,
} from '@gitlab/ui';
import { mapActions, mapGetters, mapState } from 'vuex';
import BoardAddNewColumnForm from '~/boards/components/board_add_new_column_form.vue';
import { ListType } from '~/boards/constants';
import boardsStore from '~/boards/stores/boards_store';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { isScopedLabel } from '~/lib/utils/common_utils';
import { __ } from '~/locale';

export default {
  columnTypes: [
    { value: ListType.label, text: __('Label') },
    { value: ListType.milestone, text: __('Milestone') },
    { value: ListType.iteration, text: __('Iteration') },
  ],
  components: {
    BoardAddNewColumnForm,
    GlFormGroup,
    GlFormRadio,
    GlFormRadioGroup,
    GlFormSelect,
    GlLabel,
  },
  directives: {
    GlTooltip,
  },
  inject: ['scopedLabelsAvailable'],
  data() {
    return {
      selectedId: null,
      columnType: 'label',
    };
  },
  computed: {
    ...mapState([
      'labels',
      'labelsLoading',
      'milestones',
      'milestonesLoading',
      'iterations',
      'iterationsLoading',
      'isEpicBoard',
    ]),
    ...mapGetters(['getListByTypeId', 'shouldUseGraphQL']),

    labelTypeSelected() {
      return this.columnType === ListType.label;
    },
    milestoneTypeSelected() {
      return this.columnType === ListType.milestone;
    },
    iterationTypeSelected() {
      return this.columnType === ListType.iteration;
    },

    selectedLabel() {
      if (!this.labelTypeSelected) {
        return null;
      }
      return this.labels.find(({ id }) => id === this.selectedId);
    },
    selectedMilestone() {
      if (!this.milestoneTypeSelected) {
        return null;
      }
      return this.milestones.find(({ id }) => id === this.selectedId);
    },
    selectedIteration() {
      if (!this.iterationTypeSelected) {
        return null;
      }
      return this.iterations.find(({ id }) => id === this.selectedId);
    },
    selectedItem() {
      if (!this.selectedId) {
        return null;
      }
      if (this.labelTypeSelected) {
        return this.selectedLabel;
      }
      if (this.milestoneTypeSelected) {
        return this.selectedMilestone;
      }
      if (this.iterationTypeSelected) {
        return this.selectedIteration;
      }
      return null;
    },

    columnForSelected() {
      if (!this.columnType) {
        return false;
      }

      const key = `${this.columnType}Id`;
      return this.getListByTypeId({
        [key]: this.selectedId,
      });
    },

    loading() {
      if (this.labelTypeSelected) {
        return this.labelsLoading;
      }
      if (this.milestoneTypeSelected) {
        return this.milestonesLoading;
      }
      if (this.iterationTypeSelected) {
        return this.iterationsLoading;
      }
      return false;
    },

    formDescription() {
      if (this.labelTypeSelected) {
        return __('A label list displays issues with the selected label.');
      }

      if (this.milestoneTypeSelected) {
        return __('A milestone list displays issues in the selected milestone.');
      }

      if (this.iterationTypeSelected) {
        return __('An iteration list displays issues in the selected iteration.');
      }

      return null;
    },

    searchLabel() {
      if (this.labelTypeSelected) {
        return __('Select label');
      }

      if (this.milestoneTypeSelected) {
        return __('Select milestone');
      }

      if (this.iterationTypeSelected) {
        return __('Select iteration');
      }

      return null;
    },

    searchPlaceholder() {
      if (this.labelTypeSelected) {
        return __('Search labels');
      }

      if (this.milestoneTypeSelected) {
        return __('Search milestones');
      }

      if (this.iterationTypeSelected) {
        return __('Search iterations');
      }

      return null;
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
      'fetchIterations',
      'fetchMilestones',
    ]),
    highlight(listId) {
      if (this.shouldUseGraphQL || this.isEpicBoard) {
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
      if (!this.selectedItem) {
        return;
      }

      this.setAddColumnFormVisibility(false);

      if (this.columnForSelected) {
        const listId = this.columnForSelected.id;
        this.highlight(listId);
        return;
      }

      if (this.shouldUseGraphQL || this.isEpicBoard) {
        // eslint-disable-next-line @gitlab/require-i18n-strings
        this.createList({ [`${this.columnType}Id`]: this.selectedId });
      } else {
        const listObj = {
          // eslint-disable-next-line @gitlab/require-i18n-strings
          [`${this.columnType}Id`]: getIdFromGraphQLId(this.selectedId),
          title: this.selectedItem.title,
          position: boardsStore.state.lists.length - 2,
          list_type: this.columnType,
        };

        if (this.labelTypeSelected) {
          listObj.label = this.selectedLabel;
        } else if (this.milestoneTypeSelected) {
          listObj.milestone = {
            ...this.selectedMilestone,
            id: getIdFromGraphQLId(this.selectedMilestone.id),
          };
        } else if (this.iterationTypeSelected) {
          listObj.iteration = {
            ...this.selectedIteration,
            id: getIdFromGraphQLId(this.selectedIteration.id),
          };
        }

        boardsStore.new(listObj);
      }
    },

    filterItems(searchTerm) {
      switch (this.columnType) {
        case ListType.iteration:
          this.fetchIterations(searchTerm);
          break;
        case ListType.milestone:
          this.fetchMilestones(searchTerm);
          break;
        case ListType.label:
        default:
          this.fetchLabels(searchTerm);
      }
    },

    showScopedLabels(label) {
      return this.scopedLabelsAvailable && isScopedLabel(label);
    },

    setColumnType() {
      this.selectedId = null;
      this.filterItems();
    },
  },
};
</script>

<template>
  <board-add-new-column-form
    :loading="loading"
    :form-description="formDescription"
    :search-label="searchLabel"
    :search-placeholder="searchPlaceholder"
    :selected-id="selectedId"
    @filter-items="filterItems"
    @add-list="addList"
  >
    <template slot="select-list-type">
      <gl-form-group
        v-if="!isEpicBoard"
        :label="__('List type')"
        class="gl-px-5 gl-py-0 gl-mt-5"
        label-for="list-type"
      >
        <gl-form-select
          id="list-type"
          v-model="columnType"
          :options="$options.columnTypes"
          @change="setColumnType"
        />
      </gl-form-group>
    </template>

    <template slot="selected">
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
      <div v-else-if="selectedIteration" class="gl-text-truncate">
        {{ selectedIteration.title }}
      </div>
    </template>

    <template slot="items">
      <gl-form-radio-group v-model="selectedId" class="gl-overflow-y-auto gl-px-5 gl-pt-3">
        <template v-if="labelTypeSelected">
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
        </template>
        <template v-if="milestoneTypeSelected">
          <label
            v-for="milestone in milestones"
            :key="milestone.id"
            class="gl-display-flex gl-flex-align-items-center gl-mb-5 gl-font-weight-normal"
          >
            <gl-form-radio :value="milestone.id" class="gl-mb-0 gl-mr-3" />
            <span>{{ milestone.title }}</span>
          </label>
        </template>
        <template v-if="iterationTypeSelected">
          <label
            v-for="iteration in iterations"
            :key="iteration.id"
            class="gl-display-flex gl-flex-align-items-center gl-mb-5 gl-font-weight-normal"
          >
            <gl-form-radio :value="iteration.id" class="gl-mb-0 gl-mr-3" />
            <span>{{ iteration.title }}</span>
          </label>
        </template>
      </gl-form-radio-group>
    </template>
  </board-add-new-column-form>
</template>
