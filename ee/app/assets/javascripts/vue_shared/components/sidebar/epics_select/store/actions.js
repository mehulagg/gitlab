import Api from 'ee/api';
import { noneEpic } from 'ee/vue_shared/constants';
import boardsStore from '~/boards/stores/boards_store';
import createFlash from '~/flash';

import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { formatDate, timeFor } from '~/lib/utils/datetime_utility';
import { s__, __ } from '~/locale';

import * as types from './mutation_types';

export const setInitialData = ({ commit }, data) => commit(types.SET_INITIAL_DATA, data);
export const setIssueId = ({ commit }, issueId) => commit(types.SET_ISSUE_ID, issueId);

export const setSearchQuery = ({ commit }, searchQuery) =>
  commit(types.SET_SEARCH_QUERY, searchQuery);

export const setSelectedEpic = ({ commit }, selectedEpic) =>
  commit(types.SET_SELECTED_EPIC, selectedEpic);

export const setSelectedEpicIssueId = ({ commit }, selectedEpicIssueId) =>
  commit(types.SET_SELECTED_EPIC_ISSUE_ID, selectedEpicIssueId);

export const requestEpics = ({ commit }) => commit(types.REQUEST_EPICS);
export const receiveEpicsSuccess = ({ commit }, data) => {
  const epics = data.map((rawEpic) =>
    convertObjectPropsToCamelCase(
      { ...rawEpic, url: rawEpic.web_edit_url },
      {
        dropKeys: ['web_edit_url'],
      },
    ),
  );

  commit(types.RECEIVE_EPICS_SUCCESS, { epics });
};
export const receiveEpicsFailure = ({ commit }) => {
  createFlash({
    message: s__('Epics|Something went wrong while fetching group epics.'),
  });
  commit(types.RECEIVE_EPICS_FAILURE);
};
export const fetchEpics = ({ state, dispatch }, search = '') => {
  dispatch('requestEpics');

  Api.groupEpics({
    groupId: state.groupId,
    includeDescendantGroups: false,
    includeAncestorGroups: true,
    search,
  })
    .then(({ data }) => {
      dispatch('receiveEpicsSuccess', data);
    })
    .catch(() => {
      dispatch('receiveEpicsFailure');
    });
};

export const requestIssueUpdate = ({ commit }) => commit(types.REQUEST_ISSUE_UPDATE);
export const receiveIssueUpdateSuccess = ({ state, commit }, { data, epic, isRemoval = false }) => {
  /*
   If EpicsSelect is loaded within Boards, -
    we need to update "boardsStore.issue.detail.epic" which has -
    a differently formatted timestamp that includes '<strong>' tag.
   However, "data.epic" in the response of the API POST  doesn't have '<strong>' tag.
    ("epic" param is also in a different format).
   */
  function insertStrongTag(humanReadableTimestamp) {
    if (humanReadableTimestamp === __('Past due')) {
      return `<strong>${humanReadableTimestamp}</strong>`;
    }

    // Insert strong tag for for any number in the string.
    // I.e., "3 days remaining" or "Осталось 3 дней"
    // A similar transformation is done in the backend:
    // app/serializers/entity_date_helper.rb
    return humanReadableTimestamp.replace(/\d+/, '<strong>$&</strong>');
  }

  // Verify if update was successful
  if (data.epic.id === epic.id && data.issue.id === state.issueId) {
    if (boardsStore.detail.issue.updateEpic) {
      const formattedEpic = isRemoval
        ? { epic_issue_id: noneEpic.id }
        : {
            epic_issue_id: data.id,
            group_id: data.epic.group_id,
            human_readable_end_date: formatDate(data.epic.end_date, 'mmm d, yyyy'),
            human_readable_timestamp: insertStrongTag(timeFor(data.epic.end_date)),
            id: data.epic.id,
            iid: data.epic.iid,
            title: data.epic.title,
            url: `/groups/${data.epic.web_url.replace(/.+groups\//, '')}`,
          };
      boardsStore.detail.issue.updateEpic(formattedEpic);
    }

    commit(types.RECEIVE_ISSUE_UPDATE_SUCCESS, {
      selectedEpic: isRemoval ? noneEpic : epic,
      selectedEpicIssueId: data.id,
    });
  }
};

/**
 * Shows provided errorMessage in flash banner and
 * fires `RECEIVE_ISSUE_UPDATE_FAILURE` mutation
 *
 * @param {string} errorMessage
 */
export const receiveIssueUpdateFailure = ({ commit }, errorMessage) => {
  createFlash({
    message: errorMessage,
  });
  commit(types.RECEIVE_ISSUE_UPDATE_FAILURE);
};

export const assignIssueToEpic = ({ state, dispatch }, epic) => {
  dispatch('requestIssueUpdate');

  Api.addEpicIssue({
    issueId: state.issueId,
    groupId: epic.groupId,
    epicIid: epic.iid,
  })
    .then(({ data }) => {
      dispatch('receiveIssueUpdateSuccess', {
        data,
        epic,
      });
    })
    .catch((error) => {
      // Handle specific format "#ID cannot be added: reason"
      const message = error.response.data.message.split(':')[1].trim();
      dispatch('receiveIssueUpdateFailure', message);
    })
    .catch(() => {
      // Shows flash error for Epic change failure
      dispatch(
        'receiveIssueUpdateFailure',
        s__('Epics|Something went wrong while assigning issue to epic.'),
      );
    });
};

export const removeIssueFromEpic = ({ state, dispatch }, epic) => {
  dispatch('requestIssueUpdate');

  Api.removeEpicIssue({
    epicIssueId: state.selectedEpicIssueId,
    groupId: epic.groupId,
    epicIid: epic.iid,
  })
    .then(({ data }) => {
      dispatch('receiveIssueUpdateSuccess', {
        data,
        epic,
        isRemoval: true,
      });
    })
    .catch(() => {
      // Shows flash error for Epic remove failure
      dispatch(
        'receiveIssueUpdateFailure',
        s__('Epics|Something went wrong while removing issue from epic.'),
      );
    });
};
