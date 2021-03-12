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

export default {
  i18n: {
    listType: __('List type'),
    labelListDescription: __('A label list displays issues with the selected label.'),
    assigneeListDescription: __('An assignee list displays issues assigned to the selected user'),
    milestoneListDescription: __('A milestone list displays issues in the selected milestone.'),
    selectLabel: __('Select label'),
    selectAssignee: __('Select assignee'),
    selectMilestone: __('Select milestone'),
    searchLabels: __('Search labels'),
    searchAssignees: __('Search assignees'),
    searchMilestones: __('Search milestones'),
  },
  columnTypes: [
    { value: ListType.label, text: __('Label') },
    { value: ListType.assignee, text: __('Assignee') },
    { value: ListType.milestone, text: __('Milestone') },
  ],
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
      'assignees',
      'assigneesLoading',
      'milestones',
      'milestonesLoading',
    ]),
    ...mapGetters(['getListByTypeId', 'shouldUseGraphQL', 'isEpicBoard']),

    items() {
      if (this.labelTypeSelected) {
        return this.labels;
      }
      if (this.assigneeTypeSelected) {
        return this.assignees;
      }
      if (this.milestoneTypeSelected) {
        return this.milestones;
      }
      return [];
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

    selectedLabel() {
      if (!this.labelTypeSelected) {
        return null;
      }
      return this.labels.find(({ id }) => id === this.selectedId);
    },
    selectedAssignee() {
      if (!this.assigneeTypeSelected) {
        return null;
      }
      return this.assignees.find(({ id }) => id === this.selectedId);
    },
    selectedMilestone() {
      if (!this.milestoneTypeSelected) {
        return null;
      }
      return this.milestones.find(({ id }) => id === this.selectedId);
    },
    selectedItem() {
      if (!this.selectedId) {
        return null;
      }
      if (this.labelTypeSelected) {
        return this.selectedLabel;
      }
      if (this.assigneeTypeSelected) {
        return this.selectedAssignee;
      }
      if (this.milestoneTypeSelected) {
        return this.selectedMilestone;
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
      if (this.columnType === ListType.label) {
        return this.labelsLoading;
      }
      if (this.assigneeTypeSelected) {
        return this.assigneesLoading;
      }
      if (this.columnType === ListType.milestone) {
        return this.milestonesLoading;
      }
      return false;
    },

    formDescription() {
      if (this.labelTypeSelected) {
        return this.$options.i18n.labelListDescription;
      }

      if (this.assigneeTypeSelected) {
        return this.$options.i18n.assigneeListDescription;
      }

      if (this.milestoneTypeSelected) {
        return this.$options.i18n.milestoneListDescription;
      }

      return null;
    },

    searchLabel() {
      if (this.labelTypeSelected) {
        return this.$options.i18n.selectLabel;
      }

      if (this.assigneeTypeSelected) {
        return this.$options.i18n.selectAssignee;
      }

      if (this.milestoneTypeSelected) {
        return this.$options.i18n.selectMilestone;
      }

      return null;
    },

    searchPlaceholder() {
      if (this.labelTypeSelected) {
        return this.$options.i18n.searchLabels;
      }

      if (this.assigneeTypeSelected) {
        return this.$options.i18n.searchAssignees;
      }

      if (this.milestoneTypeSelected) {
        return this.$options.i18n.searchMilestones;
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
      'fetchAssignees',
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
          listObj.label = this.selectedLabel;
        } else if (this.milestoneTypeSelected) {
          listObj.milestone = {
            ...this.selectedMilestone,
            id: getIdFromGraphQLId(this.selectedMilestone.id),
          };
        } else if (this.assigneeTypeSelected) {
          listObj.assignee = {
            ...this.selectedAssignee,
            id: getIdFromGraphQLId(this.selectedAssignee.id),
          };
        }

        boardsStore.new(listObj);
      }
    },

    filterItems(searchTerm) {
      switch (this.columnType) {
        case ListType.milestone:
          this.fetchMilestones(searchTerm);
          break;
        case ListType.assignee:
          this.fetchAssignees(searchTerm);
          break;
        case ListType.label:
        default:
          this.fetchLabels(searchTerm);
      }
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
        :label="$options.i18n.listType"
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
      <div v-if="selectedLabel">
        <gl-label
          v-gl-tooltip
          :title="selectedLabel.title"
          :description="selectedLabel.description"
          :background-color="selectedLabel.color"
          :scoped="showScopedLabels(selectedLabel)"
        />
      </div>
      <div v-else-if="selectedMilestone" class="gl-text-truncate">
        {{ selectedMilestone.title }}
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
