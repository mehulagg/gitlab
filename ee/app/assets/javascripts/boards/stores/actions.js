import { sortBy } from 'lodash';
import axios from 'axios';
import actionsCE from '~/boards/stores/actions';
import boardsStoreEE from './boards_store_ee';
import boardsStore from '~/boards/stores/boards_store';
import * as types from './mutation_types';

import createDefaultClient from '~/lib/graphql';
import { BoardType } from '~/boards/constants';
import groupEpicsSwimlanesQuery from '../queries/group_epics_swimlanes.query.graphql';
import projectEpicsSwimlanesQuery from '../queries/project_epics_swimlanes.query.graphql';

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
};

const gqlClient = createDefaultClient();

const fetchEpicsSwimlanes = ({ endpoints, boardType }) => {
  const { fullPath, boardId } = endpoints;

  const query =
    boardType === BoardType.group ? groupEpicsSwimlanesQuery : projectEpicsSwimlanesQuery;

  const variables = {
    fullPath,
    boardId: `gid://gitlab/Board/${boardId}`,
  };

  return gqlClient
    .query({
      query,
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
      return {
        epics: epicsFormatted,
        lists: lists.nodes,
      };
    });
};

export default {
  ...actionsCE,

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

  toggleEpicSwimlanes: ({ state, commit, dispatch }) => {
    commit(types.TOGGLE_EPICS_SWIMLANES);

    if (state.isShowingEpicsSwimlanes) {
      fetchEpicsSwimlanes(state)
        .then(({ lists, epics }) => {
          if (lists) {
            if (lists) {
              let boardLists = lists.map(list =>
                boardsStore.updateListPosition({ ...list, doNotFetchIssues: true }),
              );
              boardLists = sortBy([...boardLists], 'position');
              dispatch('receiveBoardListsSuccess', boardLists);
            }
          }

          if (epics) {
            dispatch('receiveEpicsSuccess', epics);
          }
        })
        .catch(() => {
          dispatch('receiveSwimlanesFailure');
        });
    }
  },

  receiveBoardListsSuccess: ({ commit }, swimlanes) => {
    commit(types.RECEIVE_BOARD_LISTS_SUCCESS, swimlanes);
  },

  receiveSwimlanesFailure: ({ commit }) => {
    commit(types.RECEIVE_SWIMLANES_FAILURE);
  },

  receiveEpicsSuccess: ({ commit }, swimlanes) => {
    commit(types.RECEIVE_EPICS_SUCCESS, swimlanes);
  },
};
