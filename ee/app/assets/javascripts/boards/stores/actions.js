import { sortBy, pick } from 'lodash';
import Cookies from 'js-cookie';
import axios from '~/lib/utils/axios_utils';
import boardsStore from '~/boards/stores/boards_store';
import { __ } from '~/locale';
import { parseBoolean } from '~/lib/utils/common_utils';
import actionsCE from '~/boards/stores/actions';
import { BoardType, ListType } from '~/boards/constants';
import { EpicFilterType } from '../constants';
import boardsStoreEE from './boards_store_ee';
import * as types from './mutation_types';
import { fullEpicId } from '../boards_util';
import { formatListIssues, fullBoardId } from '~/boards/boards_util';

import createDefaultClient from '~/lib/graphql';
import epicsSwimlanesQuery from '../queries/epics_swimlanes.query.graphql';
import listsIssuesQuery from '~/boards/queries/lists_issues.query.graphql';

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
};

export const gqlClient = createDefaultClient();

const fetchAndFormatListIssues = (state, extraVariables) => {
  const { endpoints, boardType, filterParams } = state;
  const { fullPath, boardId } = endpoints;

  const variables = {
    ...extraVariables,
    fullPath,
    boardId: fullBoardId(boardId),
    filters: { ...filterParams },
    isGroup: boardType === BoardType.group,
    isProject: boardType === BoardType.project,
  };

  return gqlClient
    .query({
      query: listsIssuesQuery,
      context: {
        isSingleRequest: true,
      },
      variables,
    })
    .then(({ data }) => {
      const { lists } = data[boardType]?.board;
      return formatListIssues(lists);
    });
};

export default {
  ...actionsCE,

  setFilters: ({ commit }, filters) => {
    const filterParams = pick(filters, [
      'assigneeUsername',
      'authorUsername',
      'epicId',
      'labelName',
      'milestoneTitle',
      'releaseTag',
      'search',
      'weight',
    ]);

    if (filterParams.epicId === EpicFilterType.any || filterParams.epicId === EpicFilterType.none) {
      filterParams.epicWildcardId = filterParams.epicId.toUpperCase();
      filterParams.epicId = undefined;
    } else if (filterParams.epicId) {
      filterParams.epicId = fullEpicId(filterParams.epicId);
    }
    commit(types.SET_FILTERS, filterParams);
  },

  fetchEpicsSwimlanes({ state, commit }, withLists = true) {
    const { endpoints, boardType, filterParams } = state;
    const { fullPath, boardId } = endpoints;

    const variables = {
      fullPath,
      boardId: `gid://gitlab/Board/${boardId}`,
      issueFilters: filterParams,
      withLists,
      isGroup: boardType === BoardType.group,
      isProject: boardType === BoardType.project,
    };

    return gqlClient
      .query({
        query: epicsSwimlanesQuery,
        variables,
      })
      .then(({ data }) => {
        const { epics, lists } = data[boardType]?.board;
        const epicsFormatted = epics.nodes.map(e => ({
          ...e,
          issues: (e?.issues?.nodes || []).map(i => ({
            ...i,
            labels: i.labels?.nodes || [],
            assignees: i.assignees?.nodes || [],
          })),
        }));

        if (!withLists) {
          commit(types.RECEIVE_EPICS_SUCCESS, epicsFormatted);
        }

        return {
          epics: epicsFormatted,
          lists: lists?.nodes,
        };
      });
  },

  setShowLabels({ commit }, val) {
    commit(types.SET_SHOW_LABELS, val);
  },

  updateListWipLimit({ state }, { maxIssueCount }) {
    const { activeId } = state;

    return axios.put(`${boardsStoreEE.store.state.endpoints.listsEndpoint}/${activeId}`, {
      list: {
        max_issue_count: maxIssueCount,
      },
    });
  },

  showPromotionList: ({ state, dispatch }) => {
    if (
      !state.showPromotion ||
      parseBoolean(Cookies.get('promotion_issue_board_hidden')) ||
      state.disabled
    ) {
      return;
    }
    dispatch('addList', {
      id: 'promotion',
      listType: ListType.promotion,
      title: __('Improve Issue Boards'),
      position: 0,
    });
  },

  fetchAllBoards: () => {
    notImplemented();
  },

  fetchRecentBoards: () => {
    notImplemented();
  },

  createBoard: () => {
    notImplemented();
  },

  deleteBoard: () => {
    notImplemented();
  },

  updateIssueWeight: () => {
    notImplemented();
  },

  togglePromotionState: () => {
    notImplemented();
  },

  fetchIssuesForList: ({ state, commit }, listId, noEpicIssues = false) => {
    const { filterParams } = state;

    const variables = {
      id: listId,
      filters: noEpicIssues
        ? { ...filterParams, epicWildcardId: EpicFilterType.none }
        : filterParams,
    };

    return fetchAndFormatListIssues(state, variables)
      .then(listIssues => {
        commit(types.RECEIVE_ISSUES_FOR_LIST_SUCCESS, { listIssues, listId });
      })
      .catch(() => commit(types.RECEIVE_ISSUES_FOR_LIST_FAILURE, listId));
  },

  fetchIssuesForEpic: ({ state, commit }, epicId) => {
    commit(types.REQUEST_ISSUES_FOR_EPIC, epicId);

    const { filterParams } = state;

    const variables = {
      filters: { ...filterParams, epicId },
    };

    return fetchAndFormatListIssues(state, variables)
      .then(listIssues => {
        commit(types.RECEIVE_ISSUES_FOR_EPIC_SUCCESS, { ...listIssues, epicId });
      })
      .catch(() => commit(types.RECEIVE_ISSUES_FOR_EPIC_FAILURE, epicId));
  },

  toggleEpicSwimlanes: ({ state, commit, dispatch }) => {
    commit(types.TOGGLE_EPICS_SWIMLANES);

    if (state.isShowingEpicsSwimlanes) {
      dispatch('fetchEpicsSwimlanes')
        .then(({ lists, epics }) => {
          if (lists) {
            let boardLists = lists.map(list =>
              boardsStore.updateListPosition({ ...list, doNotFetchIssues: true }),
            );
            boardLists = sortBy([...boardLists], 'position');
            commit(types.RECEIVE_BOARD_LISTS_SUCCESS, boardLists);
          }

          if (epics) {
            commit(types.RECEIVE_EPICS_SUCCESS, epics);
          }
        })
        .catch(() => commit(types.RECEIVE_SWIMLANES_FAILURE));
    }
  },
};
