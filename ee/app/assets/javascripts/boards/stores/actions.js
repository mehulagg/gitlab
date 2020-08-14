import axios from 'axios';
import { sortBy } from 'lodash';
import boardsStore from '~/boards/stores/boards_store';
import actionsCE from '~/boards/stores/actions';
import boardsStoreEE from './boards_store_ee';
import * as types from './mutation_types';

import createDefaultClient from '~/lib/graphql';
import epicsSwimlanes from '../queries/epics_swimlanes.query.graphql';
import groupEpics from '../queries/group_epics.query.graphql';

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
};

const gqlClient = createDefaultClient();

const fetchEpicsSwimlanes = ({ endpoints, boardType }) => {
  const { fullPath, boardId } = endpoints;

  const query = epicsSwimlanes;
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
      const { lists } = data[boardType]?.board;
      return lists?.nodes;
    });
};

const fetchEpics = ({ endpoints }) => {
  const { fullPath } = endpoints;

  const query = groupEpics;
  const variables = {
    fullPath,
  };

  return gqlClient
    .query({
      query,
      variables,
    })
    .then(({ data }) => {
      const { group } = data;
      const epics = group?.epics.nodes || [];
      return epics.map(e => ({
        ...e,
        issues: (e?.issues?.nodes || []).map(i => ({
          ...i,
          labels: i.labels?.nodes || [],
          assignees: i.assignees?.nodes || [],
        })),
      }));
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

  toggleEpicSwimlanes: ({ state, commit }) => {
    commit(types.TOGGLE_EPICS_SWIMLANES);

    if (state.isShowingEpicsSwimlanes) {
      Promise.all([fetchEpicsSwimlanes(state), fetchEpics(state)])
        .then(([lists, epics]) => {
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
