<script>
import {
  GlAvatar,
  GlIcon,
  GlFormGroup,
  GlFormRadio,
  GlFormRadioGroup,
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
  columnTypes: [
    { value: ListType.label, text: __('Label') },
    { value: ListType.assignee, text: __('Assignee') },
    { value: ListType.milestone, text: __('Milestone') },
    { value: ListType.iteration, text: __('Iteration') },
  ],
  components: {
    BoardAddNewColumnForm,
    GlAvatar,
    GlIcon,
    GlFormGroup,
    GlFormRadio,
    GlFormRadioGroup,
  },
  directives: {
    GlTooltip,
  },
  inject: ['scopedLabelsAvailable'],
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
        v-if="!isEpicBoard"
        :label="$options.i18n.listType"
        :description="$options.i18n.scopeDescription"
        class="gl-px-5 gl-py-0 gl-mt-5"
        label-for="list-type"
      >
        <gl-form-radio-group v-model="columnType">
          <gl-form-radio
            v-for="{ text, value } in $options.columnTypes"
            :key="value"
            :value="value"
            class="gl-mb-0 gl-align-self-center"
            @change="setColumnType"
          >
            {{ text }}
          </gl-form-radio>
        </gl-form-radio-group>
      </gl-form-group>
    </template>

    <template slot="selected">
      <div v-if="hasLabelSelection" class="gl-display-flex gl-flex-align-items-center">
        <span
          class="dropdown-label-box gl-top-0"
          :style="{
            backgroundColor: selectedItem.color,
          }"
        ></span>
        {{ selectedItem.title }}
      </div>

      <div
        v-else-if="hasMilestoneSelection"
        class="gl-text-truncate gl-display-flex gl-flex-align-items-center"
      >
        <gl-icon name="clock" />
        <span>{{ selectedItem.title }}</span>
      </div>

      <div v-else-if="hasIterationSelection" class="gl-text-truncate">
        <gl-icon name="iteration" />
        <span>{{ selectedItem.title }}</span>
      </div>

      <div
        v-else-if="hasAssigneeSelection"
        class="gl-text-truncate gl-display-flex gl-flex-align-items-center"
      >
        <gl-avatar :size="16" :src="selectedItem.avatarUrl" />
        <b class="gl-mr-2">{{ selectedItem.name }}</b>
        <span class="gl-text-gray-700">@{{ selectedItem.username }}</span>
      </div>
    </template>

    <template v-if="items.length > 0" slot="items">
      <gl-form-radio-group
        v-model="selectedId"
        class="gl-overflow-y-auto gl-px-5"
        @change="$root.$emit('bv::dropdown::hide')"
      >
        <label
          v-for="item in items"
          :key="item.id"
          class="gl-display-flex gl-flex-align-items-center gl-mt-3 gl-font-weight-normal"
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

      <div class="dropdown-content-faded-mask gl-fixed gl-bottom-0 gl-w-full"></div>
    </template>
  </board-add-new-column-form>
</template>
