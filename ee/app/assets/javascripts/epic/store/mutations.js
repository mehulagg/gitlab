import { dateTypes } from '../constants';

import * as types from './mutation_types';

export default {
  [types.SET_EPIC_META](state, meta) {
    Object.assign(state, { ...meta });
  },

  [types.SET_EPIC_DATA](state, data) {
    Object.assign(state, { ...data });
  },

  [types.REQUEST_EPIC_STATUS_CHANGE](state) {
    state.epicStatusChangeInProgress = true;
  },
  [types.REQUEST_EPIC_STATUS_CHANGE_SUCCESS](state, data) {
    state.state = data.state;
    state.epicStatusChangeInProgress = false;
  },
  [types.REQUEST_EPIC_STATUS_CHANGE_FAILURE](state) {
    state.epicStatusChangeInProgress = false;
  },

  [types.TOGGLE_SIDEBAR](state, isSidebarCollapsed) {
    state.sidebarCollapsed = isSidebarCollapsed;
  },

  [types.REQUEST_EPIC_TODO_TOGGLE](state) {
    state.epicTodoToggleInProgress = true;
  },
  [types.REQUEST_EPIC_TODO_TOGGLE_SUCCESS](state, { todoDeletePath }) {
    state.todoDeletePath = todoDeletePath;
    state.todoExists = !state.todoExists;
    state.epicTodoToggleInProgress = false;
  },
  [types.REQUEST_EPIC_TODO_TOGGLE_FAILURE](state) {
    state.epicTodoToggleInProgress = false;
  },

  [types.TOGGLE_EPIC_START_DATE_TYPE](state, { dateTypeIsFixed }) {
    state.startDateIsFixed = dateTypeIsFixed;
  },

  [types.TOGGLE_EPIC_DUE_DATE_TYPE](state, { dateTypeIsFixed }) {
    state.dueDateIsFixed = dateTypeIsFixed;
  },

  [types.REQUEST_EPIC_DATE_SAVE](state, { dateType }) {
    if (dateType === dateTypes.start) {
      state.epicStartDateSaveInProgress = true;
    } else {
      state.epicDueDateSaveInProgress = true;
    }
  },
  [types.REQUEST_EPIC_DATE_SAVE_SUCCESS](state, { dateType, dateTypeIsFixed, newDate }) {
    if (dateType === dateTypes.start) {
      state.epicStartDateSaveInProgress = false;
      state.startDateIsFixed = dateTypeIsFixed;
      state.startDate = newDate;

      if (dateTypeIsFixed) {
        state.startDateFixed = newDate;
      }
    } else {
      state.epicDueDateSaveInProgress = false;
      state.dueDateIsFixed = dateTypeIsFixed;
      state.dueDate = newDate;

      if (dateTypeIsFixed) {
        state.dueDateFixed = newDate;
      }
    }
  },
  [types.REQUEST_EPIC_DATE_SAVE_FAILURE](state, { dateType, dateTypeIsFixed }) {
    if (dateType === dateTypes.start) {
      state.epicStartDateSaveInProgress = false;
      state.startDateIsFixed = dateTypeIsFixed;
    } else {
      state.epicDueDateSaveInProgress = false;
      state.dueDateIsFixed = dateTypeIsFixed;
    }
  },

  [types.REQUEST_EPIC_SUBSCRIPTION_TOGGLE](state) {
    state.epicSubscriptionToggleInProgress = true;
  },
  [types.REQUEST_EPIC_SUBSCRIPTION_TOGGLE_SUCCESS](state, { subscribed }) {
    state.epicSubscriptionToggleInProgress = false;
    state.subscribed = subscribed;
  },
  [types.REQUEST_EPIC_SUBSCRIPTION_TOGGLE_FAILURE](state) {
    state.epicSubscriptionToggleInProgress = false;
  },

  [types.SET_EPIC_CREATE_TITLE](state, { newEpicTitle }) {
    state.newEpicTitle = newEpicTitle;
  },
  [types.SET_EPIC_CREATE_CONFIDENTIAL](state, { newEpicConfidential }) {
    state.newEpicConfidential = newEpicConfidential;
  },
  [types.REQUEST_EPIC_CREATE](state) {
    state.epicCreateInProgress = true;
  },
  [types.REQUEST_EPIC_CREATE_FAILURE](state) {
    state.epicCreateInProgress = false;
  },

  [types.REQUEST_EPIC_LABELS_SELECT](state) {
    state.epicLabelsSelectInProgress = true;
  },
  [types.RECEIVE_EPIC_LABELS_SELECT_SUCCESS](state, labels) {
    const addedLabels = labels.filter(label => label.set);
    const removeLabelIds = labels.filter(label => !label.set).map(label => label.id);
    const updatedLabels = state.labels.filter(label => !removeLabelIds.includes(label.id));
    updatedLabels.push(...addedLabels);

    state.epicLabelsSelectInProgress = false;
    state.labels = updatedLabels;
  },
  [types.RECEIVE_EPIC_LABELS_SELECT_FAILURE](state) {
    state.epicLabelsSelectInProgress = false;
  },
  [types.SET_EPIC_CONFIDENTIAL](state, confidential) {
    state.confidential = confidential;
  },
};
