<script>
import {
  GlAvatarLabeled,
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

export const listTypeInfo = {
  [ListType.label]: {
    listPropertyName: 'labels',
    loadingPropertyName: 'labelsLoading',
    fetchMethodName: 'fetchLabels',
    formDescription: __('A label list displays issues with the selected label.'),
    searchLabel: __('Select label'),
    searchPlaceholder: __('Search labels'),
  },
  [ListType.assignee]: {
    listPropertyName: 'assignees',
    loadingPropertyName: 'assigneesLoading',
    fetchMethodName: 'fetchAssignees',
    formDescription: __('An assignee list displays issues assigned to the selected user'),
    searchLabel: __('Select assignee'),
    searchPlaceholder: __('Search assignees'),
  },
  [ListType.milestone]: {
    listPropertyName: 'milestones',
    loadingPropertyName: 'milestonesLoading',
    fetchMethodName: 'fetchMilestones',
    formDescription: __('A milestone list displays issues in the selected milestone.'),
    searchLabel: __('Select milestone'),
    searchPlaceholder: __('Search milestones'),
  },
  [ListType.iteration]: {
    listPropertyName: 'iterations',
    loadingPropertyName: 'iterationsLoading',
    fetchMethodName: 'fetchIterations',
    formDescription: __('An iteration list displays issues in the selected iteration.'),
    searchLabel: __('Select iteration'),
    searchPlaceholder: __('Search iterations'),
  },
};

export default {
  i18n: {
    listType: __('List type'),
  },
  components: {
    BoardAddNewColumnForm,
    GlAvatarLabeled,
    GlFormGroup,
    GlFormRadio,
    GlFormRadioGroup,
    GlFormSelect,
    GlLabel,
  },
  directives: {
    GlTooltip,
  },
  inject: [
    'scopedLabelsAvailable',
    'milestoneListsAvailable',
    'assigneeListsAvailable',
    'iterationListsAvailable',
  ],
  data() {
    return {
      selectedId: null,
      columnType: ListType.label,
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
      'assignees',
      'assigneesLoading',
    ]),
    ...mapGetters(['getListByTypeId', 'shouldUseGraphQL', 'isEpicBoard']),

    info() {
      return listTypeInfo[this.columnType] || {};
    },

    items() {
      return this[this.info.listPropertyName] || [];
    },

    labelTypeSelected() {
      return this.columnType === ListType.label;
    },
    assigneeTypeSelected() {
      return this.columnType === ListType.assignee;
    },
    milestoneTypeSelected() {
      return this.columnType === ListType.milestone;
    },
    iterationTypeSelected() {
      return this.columnType === ListType.iteration;
    },

    selectedItem() {
      return this.items.find(({ id }) => id === this.selectedId);
    },

    hasLabelSelection() {
      return this.labelTypeSelected && this.selectedItem;
    },
    hasMilestoneSelection() {
      return this.milestoneTypeSelected && this.selectedItem;
    },
    hasIterationSelection() {
      return this.iterationTypeSelected && this.selectedItem;
    },
    hasAssigneeSelection() {
      return this.assigneeTypeSelected && this.selectedItem;
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
      return this[this.info.loadingPropertyName];
    },

    columnTypes() {
      const types = [{ value: ListType.label, text: __('Label') }];

      if (this.assigneeListsAvailable) {
        types.push({ value: ListType.assignee, text: __('Assignee') });
      }

      if (this.milestoneListsAvailable) {
        types.push({ value: ListType.milestone, text: __('Milestone') });
      }

      if (this.iterationListsAvailable) {
        types.push({ value: ListType.iteration, text: __('Iteration') });
      }

      return types;
    },

    showListTypeSelector() {
      return !this.isEpicBoard && this.columnTypes.length > 1;
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
      'fetchAssignees',
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
        const { length } = boardsStore.state.lists;
        const position = this.hideClosed ? length - 1 : length - 2;
        const listObj = {
          // eslint-disable-next-line @gitlab/require-i18n-strings
          [`${this.columnType}Id`]: getIdFromGraphQLId(this.selectedId),
          title: this.selectedItem.title,
          position,
          list_type: this.columnType,
        };

        if (this.labelTypeSelected) {
          listObj.label = this.selectedItem;
        } else if (this.milestoneTypeSelected) {
          listObj.milestone = {
            ...this.selectedItem,
            id: getIdFromGraphQLId(this.selectedItem.id),
          };
        } else if (this.iterationTypeSelected) {
          listObj.iteration = {
            ...this.selectedItem,
            id: getIdFromGraphQLId(this.selectedItem.id),
          };
        } else if (this.assigneeTypeSelected) {
          listObj.assignee = {
            ...this.selectedItem,
            id: getIdFromGraphQLId(this.selectedItem.id),
          };
        }

        boardsStore.new(listObj);
      }
    },

    filterItems(searchTerm) {
      this[this.info.fetchMethodName](searchTerm);
    },

    showScopedLabels(label) {
      return this.scopedLabelsAvailable && isScopedLabel(label);
    },

    setColumnType(type) {
      this.columnType = type;
      this.selectedId = null;
      this.filterItems();
    },
  },
};
</script>

<template>
  <board-add-new-column-form
    :loading="loading"
    :form-description="info.formDescription"
    :search-label="info.searchLabel"
    :search-placeholder="info.searchPlaceholder"
    :selected-id="selectedId"
    @filter-items="filterItems"
    @add-list="addList"
  >
    <template slot="select-list-type">
      <gl-form-group
        v-if="showListTypeSelector"
        :label="$options.i18n.listType"
        class="gl-px-5 gl-py-0 gl-mt-5"
        label-for="list-type"
      >
        <gl-form-select
          id="list-type"
          v-model="columnType"
          :options="columnTypes"
          @change="setColumnType"
        />
      </gl-form-group>
    </template>

    <template slot="selected">
      <div v-if="hasLabelSelection">
        <gl-label
          v-gl-tooltip
          :title="selectedItem.title"
          :description="selectedItem.description"
          :background-color="selectedItem.color"
          :scoped="showScopedLabels(selectedItem)"
        />
      </div>

      <div v-else-if="hasAssigneeSelection">
        <gl-avatar-labeled
          :size="32"
          :label="selectedItem.name"
          :sub-label="selectedItem.username"
          :src="selectedItem.avatarUrl"
        />
      </div>
      <div v-else-if="hasMilestoneSelection || hasIterationSelection" class="gl-text-truncate">
        {{ selectedItem.title }}
      </div>
    </template>

    <template slot="items">
      <gl-form-radio-group
        v-if="items.length > 0"
        v-model="selectedId"
        class="gl-overflow-y-auto gl-px-5 gl-pt-3"
      >
        <label
          v-for="item in items"
          :key="item.id"
          class="gl-display-flex gl-flex-align-items-center gl-mb-5 gl-font-weight-normal"
        >
          <gl-form-radio :value="item.id" class="gl-mb-0 gl-align-self-center" />
          <span
            v-if="labelTypeSelected"
            class="dropdown-label-box gl-top-0"
            :style="{
              backgroundColor: item.color,
            }"
          ></span>

          <gl-avatar-labeled
            v-if="assigneeTypeSelected"
            :size="32"
            :label="item.name"
            :sub-label="item.username"
            :src="item.avatarUrl"
          />
          <span v-else>{{ item.title }}</span>
        </label>
      </gl-form-radio-group>
    </template>
  </board-add-new-column-form>
</template>
