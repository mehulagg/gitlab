import { pick } from 'lodash';
import axios from '~/lib/utils/axios_utils';
import boardsStore from '~/boards/stores/boards_store';
import {
  historyPushState,
  convertObjectPropsToCamelCase,
  urlParamsToObject,
} from '~/lib/utils/common_utils';
import { mergeUrlParams, removeParams } from '~/lib/utils/url_utility';
import actionsCE from '~/boards/stores/actions';
import { BoardType } from '~/boards/constants';
import * as typesCE from '~/boards/stores/mutation_types';
import {
  formatBoardLists,
  formatListIssues,
  formatListsPageInfo,
  fullBoardId,
} from '~/boards/boards_util';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import eventHub from '~/boards/eventhub';
import createGqClient, { fetchPolicies } from '~/lib/graphql';
import listsIssuesQuery from '~/boards/graphql/lists_issues.query.graphql';
import { fullEpicId } from '../boards_util';

import epicQuery from '../graphql/epic.query.graphql';
import epicsSwimlanesQuery from '../graphql/epics_swimlanes.query.graphql';
import issueSetEpicMutation from '../graphql/issue_set_epic.mutation.graphql';
import issueSetWeightMutation from '../graphql/issue_set_weight.mutation.graphql';
import { EpicFilterType, IterationFilterType, GroupByParamType } from '../constants';
import issueMoveListMutation from '../graphql/issue_move_list.mutation.graphql';
import listUpdateLimitMetricsMutation from '../graphql/list_update_limit_metrics.mutation.graphql';
import updateBoardEpicUserPreferencesMutation from '../graphql/updateBoardEpicUserPreferences.mutation.graphql';
import * as types from './mutation_types';
import boardsStoreEE from './boards_store_ee';

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
};

export const gqlClient = createGqClient(
  {},
  {
    fetchPolicy: fetchPolicies.NO_CACHE,
  },
);

const fetchAndFormatListIssues = (state, extraVariables) => {
  const { fullPath, boardId, boardType, filterParams } = state;

  const variables = {
    fullPath,
    boardId: fullBoardId(boardId),
    filters: { ...filterParams },
    isGroup: boardType === BoardType.group,
    isProject: boardType === BoardType.project,
    ...extraVariables,
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
      return { listIssues: formatListIssues(lists), listPageInfo: formatListsPageInfo(lists) };
    });
};

export default {
  ...actionsCE,

  setFilters: ({ commit, dispatch }, filters) => {
    const filterParams = pick(filters, [
      'assigneeUsername',
      'authorUsername',
      'epicId',
      'labelName',
      'milestoneTitle',
      'iterationTitle',
      'releaseTag',
      'search',
      'weight',
    ]);

    if (filters.groupBy === GroupByParamType.epic) {
      dispatch('setEpicSwimlanes');
    }

    if (filterParams.epicId === EpicFilterType.any || filterParams.epicId === EpicFilterType.none) {
      filterParams.epicWildcardId = filterParams.epicId.toUpperCase();
      filterParams.epicId = undefined;
    } else if (filterParams.epicId) {
      filterParams.epicId = fullEpicId(filterParams.epicId);
    }

    if (
      filters.iterationId === IterationFilterType.any ||
      filters.iterationId === IterationFilterType.none ||
      filters.iterationId === IterationFilterType.current
    ) {
      filterParams.iterationWildcardId = filters.iterationId.toUpperCase();
    }

    commit(types.SET_FILTERS, filterParams);
  },

  performSearch({ dispatch, getters }) {
    dispatch(
      'setFilters',
      convertObjectPropsToCamelCase(urlParamsToObject(window.location.search)),
    );

    if (getters.isSwimlanesOn) {
      dispatch('resetEpics');
      dispatch('resetIssues');
      dispatch('fetchEpicsSwimlanes', {});
    } else if (gon.features.graphqlBoardLists) {
      dispatch('fetchLists');
      dispatch('resetIssues');
    }
  },

  fetchEpicsSwimlanes({ state, commit, dispatch }, { withLists = true, endCursor = null }) {
    const { fullPath, boardId, boardType, filterParams } = state;

    const variables = {
      fullPath,
      boardId: `gid://gitlab/Board/${boardId}`,
      issueFilters: filterParams,
      withLists,
      isGroup: boardType === BoardType.group,
      isProject: boardType === BoardType.project,
      after: endCursor,
    };

    return gqlClient
      .query({
        query: epicsSwimlanesQuery,
        variables,
      })
      .then(({ data }) => {
        const { epics, lists } = data[boardType]?.board;
        const epicsFormatted = epics.edges.map((e) => ({
          ...e.node,
        }));

        if (!withLists) {
          commit(types.RECEIVE_EPICS_SUCCESS, epicsFormatted);
          commit(types.UPDATE_CACHED_EPICS, epicsFormatted);
        } else {
          if (lists) {
            commit(types.RECEIVE_BOARD_LISTS_SUCCESS, formatBoardLists(lists));
          }

          if (epicsFormatted) {
            commit(types.RECEIVE_FIRST_EPICS_SUCCESS, {
              epics: epicsFormatted,
              canAdminEpic: epics.edges[0]?.node?.userPermissions?.adminEpic,
            });
            commit(types.UPDATE_CACHED_EPICS, epicsFormatted);
          }
        }

        if (epics.pageInfo?.hasNextPage) {
          dispatch('fetchEpicsSwimlanes', {
            withLists: false,
            endCursor: epics.pageInfo.endCursor,
          });
        }
      })
      .catch(() => commit(types.RECEIVE_SWIMLANES_FAILURE));
  },

  updateBoardEpicUserPreferences({ commit, state }, { epicId, collapsed }) {
    const { boardId } = state;

    const variables = {
      boardId: fullBoardId(boardId),
      epicId,
      collapsed,
    };

    return gqlClient
      .mutate({
        mutation: updateBoardEpicUserPreferencesMutation,
        variables,
      })
      .then(({ data }) => {
        if (data?.updateBoardEpicUserPreferences?.errors.length) {
          throw new Error();
        }

        const { epicUserPreferences: userPreferences } = data?.updateBoardEpicUserPreferences;
        commit(types.SET_BOARD_EPIC_USER_PREFERENCES, { epicId, userPreferences });
      })
      .catch(() => {
        commit(types.SET_BOARD_EPIC_USER_PREFERENCES, {
          epicId,
          userPreferences: {
            collapsed: !collapsed,
          },
        });
      });
  },

  setShowLabels({ commit }, val) {
    commit(types.SET_SHOW_LABELS, val);
  },

  updateListWipLimit({ commit, getters }, { maxIssueCount, listId }) {
    if (getters.shouldUseGraphQL) {
      return gqlClient
        .mutate({
          mutation: listUpdateLimitMetricsMutation,
          variables: {
            input: {
              listId,
              maxIssueCount,
            },
          },
        })
        .then(({ data }) => {
          if (data?.boardListUpdateLimitMetrics?.errors.length) {
            commit(types.UPDATE_LIST_FAILURE);
          } else {
            const list = data.boardListUpdateLimitMetrics?.list;
            commit(types.UPDATE_LIST_SUCCESS, {
              listId,
              list,
            });
          }
        })
        .catch(() => commit(types.UPDATE_LIST_FAILURE));
    }

    return axios.put(`${boardsStoreEE.store.state.endpoints.listsEndpoint}/${listId}`, {
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

  deleteBoard: () => {
    notImplemented();
  },

  updateIssueWeight: () => {
    notImplemented();
  },

  fetchIssuesForList: ({ state, commit }, { listId, fetchNext = false, noEpicIssues = false }) => {
    commit(types.REQUEST_ISSUES_FOR_LIST, { listId, fetchNext });

    const { epicId, ...filterParams } = state.filterParams;
    if (noEpicIssues && epicId !== undefined) {
      return null;
    }

    const variables = {
      id: listId,
      filters: noEpicIssues
        ? { ...filterParams, epicWildcardId: EpicFilterType.none.toUpperCase() }
        : { ...filterParams, epicId },
      after: fetchNext ? state.pageInfoByListId[listId].endCursor : undefined,
      first: 20,
    };

    return fetchAndFormatListIssues(state, variables)
      .then(({ listIssues, listPageInfo }) => {
        commit(types.RECEIVE_ISSUES_FOR_LIST_SUCCESS, {
          listIssues,
          listPageInfo,
          listId,
          noEpicIssues,
        });
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
      .then(({ listIssues }) => {
        commit(types.RECEIVE_ISSUES_FOR_EPIC_SUCCESS, { ...listIssues, epicId });
      })
      .catch(() => commit(types.RECEIVE_ISSUES_FOR_EPIC_FAILURE, epicId));
  },

  toggleEpicSwimlanes: ({ state, commit, dispatch }) => {
    commit(types.TOGGLE_EPICS_SWIMLANES);

    if (state.isShowingEpicsSwimlanes) {
      historyPushState(
        mergeUrlParams({ group_by: GroupByParamType.epic }, window.location.href, {
          spreadArrays: true,
        }),
      );
      dispatch('fetchEpicsSwimlanes', {});
    } else if (!gon.features.graphqlBoardLists) {
      historyPushState(removeParams(['group_by']), window.location.href, true);
      boardsStore.create();
      eventHub.$emit('initialBoardLoad');
    } else {
      historyPushState(removeParams(['group_by']), window.location.href, true);
    }
  },

  setEpicSwimlanes: ({ commit, dispatch }) => {
    commit(types.SET_EPICS_SWIMLANES);

    dispatch('fetchEpicsSwimlanes', {});
  },

  resetEpics: ({ commit }) => {
    commit(types.RESET_EPICS);
  },

  fetchEpicForActiveIssue: async ({ state, commit, getters }) => {
    if (!getters.activeIssue.epic) {
      return false;
    }

    const {
      epic: { id, iid },
    } = getters.activeIssue;

    if (state.epicsCacheById[id]) {
      return false;
    }

    commit(types.SET_EPIC_FETCH_IN_PROGRESS, true);

    try {
      const {
        data: {
          group: { epic },
        },
      } = await gqlClient.query({
        query: epicQuery,
        variables: {
          fullPath: getters.groupPathForActiveIssue,
          iid,
        },
      });

      commit(types.UPDATE_CACHED_EPICS, [epic]);
    } finally {
      commit(types.SET_EPIC_FETCH_IN_PROGRESS, false);
    }

    return true;
  },

  setActiveIssueEpic: async ({ state, commit, getters }, epicId) => {
    commit(types.SET_EPIC_FETCH_IN_PROGRESS, true);

    const { data } = await gqlClient.mutate({
      mutation: issueSetEpicMutation,
      variables: {
        input: {
          iid: String(getters.activeIssue.iid),
          epicId,
          projectPath: getters.projectPathForActiveIssue,
        },
      },
    });

    if (data.issueSetEpic.errors?.length > 0) {
      throw new Error(data.issueSetEpic.errors);
    }

    const { epic } = data.issueSetEpic.issue;

    if (epic !== null) {
      commit(types.RECEIVE_FIRST_EPICS_SUCCESS, { epics: [epic, ...state.epics] });
      commit(types.UPDATE_CACHED_EPICS, [epic]);
    }

    commit(typesCE.UPDATE_ISSUE_BY_ID, {
      issueId: getters.activeIssue.id,
      prop: 'epic',
      value: epic ? { id: epic.id, iid: epic.iid } : null,
    });
    commit(types.SET_EPIC_FETCH_IN_PROGRESS, false);
  },

  setActiveIssueWeight: async ({ commit, getters }, input) => {
    const { data } = await gqlClient.mutate({
      mutation: issueSetWeightMutation,
      variables: {
        input: {
          iid: String(getters.activeIssue.iid),
          weight: input.weight,
          projectPath: input.projectPath,
        },
      },
    });

    if (!data.issueSetWeight || data.issueSetWeight?.errors?.length > 0) {
      throw new Error(data.issueSetWeight?.errors);
    }

    commit(typesCE.UPDATE_ISSUE_BY_ID, {
      issueId: getters.activeIssue.id,
      prop: 'weight',
      value: data.issueSetWeight.issue.weight,
    });
  },

  moveIssue: (
    { state, commit },
    { issueId, issueIid, issuePath, fromListId, toListId, moveBeforeId, moveAfterId, epicId },
  ) => {
    const originalIssue = state.issues[issueId];
    const fromList = state.issuesByListId[fromListId];
    const originalIndex = fromList.indexOf(Number(issueId));
    commit(types.MOVE_ISSUE, {
      originalIssue,
      fromListId,
      toListId,
      moveBeforeId,
      moveAfterId,
      epicId,
    });

    const { boardId } = state;
    const [fullProjectPath] = issuePath.split(/[#]/);

    gqlClient
      .mutate({
        mutation: issueMoveListMutation,
        variables: {
          projectPath: fullProjectPath,
          boardId: fullBoardId(boardId),
          iid: issueIid,
          fromListId: getIdFromGraphQLId(fromListId),
          toListId: getIdFromGraphQLId(toListId),
          moveBeforeId,
          moveAfterId,
          epicId,
        },
      })
      .then(({ data }) => {
        if (data?.issueMoveList?.errors.length) {
          commit(types.MOVE_ISSUE_FAILURE, { originalIssue, fromListId, toListId, originalIndex });
        } else {
          const issue = data.issueMoveList?.issue;
          commit(types.MOVE_ISSUE_SUCCESS, { issue });
        }
      })
      .catch(() =>
        commit(types.MOVE_ISSUE_FAILURE, { originalIssue, fromListId, toListId, originalIndex }),
      );
  },
};
