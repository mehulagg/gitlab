<script>
import { uniqueId } from 'lodash';
import { GlLoadingIcon, GlButton, GlIcon } from '@gitlab/ui';

import { __, s__ } from '~/locale';
import { dateInWords } from '~/lib/utils/datetime_utility';

import tooltip from '~/vue_shared/directives/tooltip';
import popover from '~/vue_shared/directives/popover';
import DatePicker from '~/vue_shared/components/pikaday.vue';
import CollapsedCalendarIcon from '~/vue_shared/components/sidebar/collapsed_calendar_icon.vue';
import ToggleSidebar from '~/vue_shared/components/sidebar/toggle_sidebar.vue';

const label = __('Date picker');
const pickerLabel = __('Fixed date');

export default {
  directives: {
    tooltip,
    popover,
  },
  components: {
    GlIcon,
    DatePicker,
    CollapsedCalendarIcon,
    ToggleSidebar,
    GlLoadingIcon,
    GlButton,
  },
  props: {
    sidebarCollapsed: {
      type: Boolean,
      required: false,
      default: true,
    },
    label: {
      type: String,
      required: false,
      default: label,
    },
    datePickerLabel: {
      type: String,
      required: false,
      default: pickerLabel,
    },
    dateInvalidTooltip: {
      type: String,
      required: false,
      default: '',
    },
    blockClass: {
      type: String,
      required: false,
      default: '',
    },
    showToggleSidebar: {
      type: Boolean,
      required: false,
      default: false,
    },
    dateSaveInProgress: {
      type: Boolean,
      required: false,
      default: false,
    },
    selectedDateIsFixed: {
      type: Boolean,
      required: false,
      default: true,
    },
    dateFixed: {
      type: Date,
      required: false,
      default: null,
    },
    dateFromMilestones: {
      type: Date,
      required: false,
      default: null,
    },
    selectedDate: {
      type: Date,
      required: false,
      default: null,
    },
    dateFromMilestonesTooltip: {
      type: String,
      required: false,
      default: '',
    },
    canUpdate: {
      type: Boolean,
      required: false,
      default: false,
    },
    isDateInvalid: {
      type: Boolean,
      required: false,
      default: true,
    },
    fieldName: {
      type: String,
      required: false,
      default: () => uniqueId('dateType_'),
    },
  },
  data() {
    return {
      editing: false,
    };
  },
  computed: {
    selectedAndEditable() {
      return this.selectedDate && this.canUpdate;
    },
    selectedDateWords() {
      return dateInWords(this.selectedDate, true);
    },
    dateFixedWords() {
      return dateInWords(this.dateFixed, true);
    },
    dateFromMilestonesWords() {
      return this.dateFromMilestones ? dateInWords(this.dateFromMilestones, true) : __('None');
    },
    collapsedText() {
      return this.selectedDateWords ? this.selectedDateWords : __('None');
    },
    popoverOptions() {
      return this.getPopoverConfig({
        title: s__(
          'Epics|These dates affect how your epics appear in the roadmap. Dates from milestones come from the milestones assigned to issues in the epic. You can also set fixed dates or remove them entirely.',
        ),
        content: `
          <a
            href="${gon.gitlab_url}/help/user/group/epics/index.md#start-date-and-due-date"
            target="_blank"
            rel="noopener noreferrer"
          >${s__('Epics|More information')}</a>
        `,
      });
    },
    dateInvalidPopoverOptions() {
      return this.getPopoverConfig({
        title: this.dateInvalidTooltip,
        content: `
          <a
            href="${gon.gitlab_url}/help/user/group/epics/index.md#start-date-and-due-date"
            target="_blank"
            rel="noopener noreferrer"
          >${s__('Epics|How can I solve this?')}</a>
        `,
      });
    },
  },
  methods: {
    getPopoverConfig({ title, content }) {
      return {
        html: true,
        trigger: 'focus',
        container: 'body',
        boundary: 'viewport',
        template: `
          <div class="popover" role="tooltip">
            <div class="arrow"></div>
            <div class="popover-header"></div>
            <div class="popover-body"></div>
          </div>
        `,
        title,
        content,
      };
    },
    stopEditing() {
      this.editing = false;
      this.$emit('toggleDateType', true, true);
    },
    startEditing(e) {
      this.editing = true;
      e.stopPropagation();
    },
    newDateSelected(date = null) {
      this.editing = false;
      this.$emit('saveDate', date);
    },
    toggleDateType(dateTypeFixed) {
      this.$emit('toggleDateType', dateTypeFixed);
    },
    toggleSidebar() {
      this.$emit('toggleCollapse');
    },
  },
};
</script>

<template>
  <div :class="blockClass" class="block date">
    <collapsed-calendar-icon :text="collapsedText" class="sidebar-collapsed-icon" />
    <div class="title">
      {{ label }}
      <gl-loading-icon v-if="dateSaveInProgress" :inline="true" />
      <div class="float-right d-flex">
        <gl-icon
          v-popover="popoverOptions"
          name="question-o"
          class="help-icon gl-mr-2"
          tabindex="0"
        />
        <gl-button
          v-show="canUpdate && !editing"
          ref="editButton"
          variant="link"
          class="btn-sidebar-action"
          @click="startEditing"
        >
          {{ __('Edit') }}
        </gl-button>

        <toggle-sidebar
          v-if="showToggleSidebar"
          :collapsed="sidebarCollapsed"
          @toggle="toggleSidebar"
        />
      </div>
    </div>
    <div class="value">
      <div
        :class="{ 'is-option-selected': selectedDateIsFixed, 'd-flex': !editing }"
        class="value-type-fixed text-secondary"
      >
        <input
          v-if="canUpdate && !editing"
          :name="fieldName"
          :checked="selectedDateIsFixed"
          type="radio"
          @click="toggleDateType(true)"
        />
        <span v-show="!editing" class="gl-ml-2">{{ __('Fixed:') }}</span>
        <date-picker
          v-if="editing"
          :selected-date="dateFixed"
          :label="datePickerLabel"
          @newDateSelected="newDateSelected"
          @hidePicker="stopEditing"
        />
        <span v-else class="d-flex value-content gl-ml-1">
          <template v-if="dateFixed">
            <span>{{ dateFixedWords }}</span>
            <gl-icon
              v-if="isDateInvalid && selectedDateIsFixed"
              v-popover="dateInvalidPopoverOptions"
              name="warning"
              class="date-warning-icon gl-mr-2 gl-ml-2"
              tabindex="0"
            />
            <span v-if="selectedAndEditable" class="no-value d-flex">
              &nbsp;&ndash;&nbsp;
              <gl-button
                ref="removeButton"
                variant="link"
                class="btn-sidebar-date-remove"
                @click="newDateSelected(null)"
              >
                {{ __('remove') }}
              </gl-button>
            </span>
          </template>
          <span v-else class="no-value"> {{ __('None') }} </span>
        </span>
      </div>
      <abbr
        v-tooltip
        :title="dateFromMilestonesTooltip"
        :class="{ 'is-option-selected': !selectedDateIsFixed }"
        class="value-type-dynamic text-secondary d-flex gl-mt-3"
        data-placement="bottom"
        data-html="true"
      >
        <input
          v-if="canUpdate"
          :name="fieldName"
          :checked="!selectedDateIsFixed"
          type="radio"
          @click="toggleDateType(false)"
        />
        <span class="gl-ml-2">{{ __('Inherited:') }}</span>
        <span class="value-content gl-ml-1">{{ dateFromMilestonesWords }}</span>
        <gl-icon
          v-if="isDateInvalid && !selectedDateIsFixed"
          v-popover="dateInvalidPopoverOptions"
          name="warning"
          class="date-warning-icon gl-ml-2"
          tabindex="0"
        />
      </abbr>
    </div>
  </div>
</template>
