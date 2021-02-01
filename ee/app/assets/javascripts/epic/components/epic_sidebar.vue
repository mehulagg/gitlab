<script>
import { mapState, mapGetters, mapActions } from 'vuex';

import AncestorsTree from 'ee/sidebar/components/ancestors_tree/ancestors_tree.vue';

import SidebarDatePickerCollapsed from '~/vue_shared/components/sidebar/collapsed_grouped_date_picker.vue';
import SidebarParticipants from '~/sidebar/components/participants/participants.vue';
import ConfidentialIssueSidebar from '~/sidebar/components/confidential/confidential_issue_sidebar.vue';
import notesEventHub from '~/notes/event_hub';
import sidebarEventHub from '~/sidebar/event_hub';
import epicUtils from '../utils/epic_utils';

import { dateTypes } from '../constants';
import SidebarHeader from './sidebar_items/sidebar_header.vue';
import SidebarTodo from './sidebar_items/sidebar_todo.vue';
import SidebarDatePicker from './sidebar_items/sidebar_date_picker.vue';
import SidebarLabels from './sidebar_items/sidebar_labels.vue';
import SidebarSubscription from './sidebar_items/sidebar_subscription.vue';

export default {
  dateTypes,
  components: {
    SidebarHeader,
    SidebarTodo,
    SidebarDatePicker,
    SidebarDatePickerCollapsed,
    SidebarLabels,
    AncestorsTree,
    SidebarParticipants,
    SidebarSubscription,
    ConfidentialIssueSidebar,
  },
  computed: {
    ...mapState([
      'canUpdate',
      'allowSubEpics',
      'sidebarCollapsed',
      'participants',
      'startDateSourcingMilestoneTitle',
      'startDateSourcingMilestoneDates',
      'startDateIsFixed',
      'startDateFixed',
      'startDateFromMilestones',
      'dueDateSourcingMilestoneTitle',
      'dueDateSourcingMilestoneDates',
      'dueDateIsFixed',
      'dueDateFixed',
      'dueDateFromMilestones',
      'epicStartDateSaveInProgress',
      'epicDueDateSaveInProgress',
      'fullPath',
    ]),
    ...mapGetters([
      'isUserSignedIn',
      'isDateInvalid',
      'startDateTimeFixed',
      'startDateTimeFromMilestones',
      'startDateTime',
      'startDateForCollapsedSidebar',
      'dueDateTimeFixed',
      'dueDateTimeFromMilestones',
      'dueDateTime',
      'dueDateForCollapsedSidebar',
      'ancestors',
    ]),
  },
  mounted() {
    this.toggleSidebarFlag(epicUtils.getCollapsedGutter());
    this.fetchEpicDetails();
    sidebarEventHub.$on('updateIssuableConfidentiality', this.updateEpicConfidentiality);
  },
  beforeDestroy() {
    sidebarEventHub.$off('updateIssuableConfidentiality', this.updateEpicConfidentiality);
  },
  methods: {
    ...mapActions([
      'fetchEpicDetails',
      'toggleSidebar',
      'toggleSidebarFlag',
      'toggleStartDateType',
      'toggleDueDateType',
      'saveDate',
    ]),
    getDateFromMilestonesTooltip(dateType) {
      return epicUtils.getDateFromMilestonesTooltip({
        dateType,
        startDateSourcingMilestoneTitle: this.startDateSourcingMilestoneTitle,
        startDateSourcingMilestoneDates: this.startDateSourcingMilestoneDates,
        startDateTimeFromMilestones: this.startDateTimeFromMilestones,
        dueDateSourcingMilestoneTitle: this.dueDateSourcingMilestoneTitle,
        dueDateSourcingMilestoneDates: this.dueDateSourcingMilestoneDates,
        dueDateTimeFromMilestones: this.dueDateTimeFromMilestones,
      });
    },
    changeStartDateType(dateTypeIsFixed, typeChangeOnEdit) {
      this.toggleStartDateType({ dateTypeIsFixed });
      if (!typeChangeOnEdit) {
        this.saveDate({
          newDate: dateTypeIsFixed ? this.startDateFixed : this.startDateFromMilestones,
          dateType: dateTypes.start,
          dateTypeIsFixed,
        });
      }
    },
    saveStartDate(date) {
      this.saveDate({
        dateType: dateTypes.start,
        newDate: date,
        dateTypeIsFixed: true,
      });
    },
    changeDueDateType(dateTypeIsFixed, typeChangeOnEdit) {
      this.toggleDueDateType({ dateTypeIsFixed });
      if (!typeChangeOnEdit) {
        this.saveDate({
          newDate: dateTypeIsFixed ? this.dueDateFixed : this.dueDateFromMilestones,
          dateType: dateTypes.due,
          dateTypeIsFixed,
        });
      }
    },
    saveDueDate(date) {
      this.saveDate({
        dateType: dateTypes.due,
        newDate: date,
        dateTypeIsFixed: true,
      });
    },
    updateEpicConfidentiality(confidential) {
      notesEventHub.$emit('notesApp.updateIssuableConfidentiality', confidential);
    },
  },
};
</script>

<template>
  <aside
    :class="{
      'right-sidebar-expanded': !sidebarCollapsed,
      'right-sidebar-collapsed': sidebarCollapsed,
    }"
    :data-signed-in="isUserSignedIn"
    class="right-sidebar epic-sidebar"
  >
    <div class="issuable-sidebar js-issuable-update">
      <sidebar-header :sidebar-collapsed="sidebarCollapsed" />
      <sidebar-todo
        v-show="sidebarCollapsed && isUserSignedIn"
        :sidebar-collapsed="sidebarCollapsed"
        data-testid="todo"
      />
      <sidebar-date-picker
        v-show="!sidebarCollapsed"
        :can-update="canUpdate"
        :sidebar-collapsed="sidebarCollapsed"
        :show-toggle-sidebar="!isUserSignedIn"
        :label="__('Start date')"
        :date-picker-label="__('Fixed start date')"
        :date-invalid-tooltip="
          __('This date is after the due date, so this epic won\'t appear in the roadmap.')
        "
        :date-from-milestones-tooltip="getDateFromMilestonesTooltip($options.dateTypes.start)"
        :date-save-in-progress="epicStartDateSaveInProgress"
        :selected-date-is-fixed="startDateIsFixed"
        :date-fixed="startDateTimeFixed"
        :date-from-milestones="startDateTimeFromMilestones"
        :selected-date="startDateTime"
        :is-date-invalid="isDateInvalid"
        data-testid="start-date"
        block-class="start-date"
        @toggleCollapse="toggleSidebar({ sidebarCollapsed })"
        @toggleDateType="changeStartDateType"
        @saveDate="saveStartDate"
      />
      <sidebar-date-picker
        v-show="!sidebarCollapsed"
        :can-update="canUpdate"
        :sidebar-collapsed="sidebarCollapsed"
        :label="__('Due date')"
        :date-picker-label="__('Fixed due date')"
        :date-invalid-tooltip="
          __('This date is before the start date, so this epic won\'t appear in the roadmap.')
        "
        :date-from-milestones-tooltip="getDateFromMilestonesTooltip($options.dateTypes.due)"
        :date-save-in-progress="epicDueDateSaveInProgress"
        :selected-date-is-fixed="dueDateIsFixed"
        :date-fixed="dueDateTimeFixed"
        :date-from-milestones="dueDateTimeFromMilestones"
        :selected-date="dueDateTime"
        :is-date-invalid="isDateInvalid"
        data-testid="due-date"
        block-class="due-date"
        @toggleDateType="changeDueDateType"
        @saveDate="saveDueDate"
      />
      <sidebar-date-picker-collapsed
        v-show="sidebarCollapsed"
        :collapsed="sidebarCollapsed"
        :min-date="startDateForCollapsedSidebar"
        :max-date="dueDateForCollapsedSidebar"
        @toggleCollapse="toggleSidebar({ sidebarCollapsed })"
      />
      <sidebar-labels
        :can-update="canUpdate"
        :sidebar-collapsed="sidebarCollapsed"
        data-testid="labels-select"
      />
      <div v-if="allowSubEpics" class="block ancestors">
        <ancestors-tree :ancestors="ancestors" :is-fetching="false" data-testid="ancestors" />
      </div>

      <confidential-issue-sidebar
        :is-editable="canUpdate"
        :full-path="fullPath"
        issuable-type="epic"
      />

      <div class="block participants">
        <sidebar-participants
          :participants="participants"
          @toggleSidebar="toggleSidebar({ sidebarCollapsed })"
        />
      </div>
      <sidebar-subscription :sidebar-collapsed="sidebarCollapsed" data-testid="subscribe" />
    </div>
  </aside>
</template>
