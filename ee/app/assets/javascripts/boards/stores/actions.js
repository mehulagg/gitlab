import { pick } from 'lodash';
import {
  formatBoardLists,
  formatListIssues,
  formatListsPageInfo,
  fullBoardId,
  transformNotFilters,
} from '~/boards/boards_util';
import { BoardType } from '~/boards/constants';
import eventHub from '~/boards/eventhub';
import listsIssuesQuery from '~/boards/graphql/lists_issues.query.graphql';
import actionsCE from '~/boards/stores/actions';
import boardsStore from '~/boards/stores/boards_store';
import * as typesCE from '~/boards/stores/mutation_types';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import createGqClient, { fetchPolicies } from '~/lib/graphql';
import axios from '~/lib/utils/axios_utils';
import {
  historyPushState,
  convertObjectPropsToCamelCase,
  urlParamsToObject,
} from '~/lib/utils/common_utils';
import { mergeUrlParams, removeParams } from '~/lib/utils/url_utility';
import {
  fullEpicId,
  fullEpicBoardId,
  formatListEpics,
  formatEpicListsPageInfo,
} from '../boards_util';

import { EpicFilterType, IterationFilterType, GroupByParamType } from '../constants';
import epicQuery from '../graphql/epic.query.graphql';
import createEpicBoardListMutation from '../graphql/epic_board_list_create.mutation.graphql';
import epicBoardListsQuery from '../graphql/epic_board_lists.query.graphql';
import epicMoveListMutation from '../graphql/epic_move_list.mutation.graphql';
import epicsSwimlanesQuery from '../graphql/epics_swimlanes.query.graphql';
import groupBoardAssigneesQuery from '../graphql/group_board_assignees.query.graphql';
import groupBoardIterationsQuery from '../graphql/group_board_iterations.query.graphql';
import groupBoardMilestonesQuery from '../graphql/group_board_milestones.query.graphql';
import issueMoveListMutation from '../graphql/issue_move_list.mutation.graphql';
import issueSetEpicMutation from '../graphql/issue_set_epic.mutation.graphql';
import issueSetWeightMutation from '../graphql/issue_set_weight.mutation.graphql';
import listUpdateLimitMetricsMutation from '../graphql/list_update_limit_metrics.mutation.graphql';
import listsEpicsQuery from '../graphql/lists_epics.query.graphql';
import projectBoardAssigneesQuery from '../graphql/project_board_assignees.query.graphql';
import projectBoardIterationsQuery from '../graphql/project_board_iterations.query.graphql';
import projectBoardMilestonesQuery from '../graphql/project_board_milestones.query.graphql';
import updateBoardEpicUserPreferencesMutation from '../graphql/update_board_epic_user_preferences.mutation.graphql';
import updateEpicLabelsMutation from '../graphql/update_epic_labels.mutation.graphql';

import boardsStoreEE from './boards_store_ee';
import * as types from './mutation_types';

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
      return { listItems: formatListIssues(lists), listPageInfo: formatListsPageInfo(lists) };
    });
};

const fetchAndFormatListEpics = (state, extraVariables) => {
  const { fullPath, boardId, filterParams } = state;

  const variables = {
    fullPath,
    boardId: fullEpicBoardId(boardId),
    filters: { ...filterParams },
    ...extraVariables,
  };

  return gqlClient
    .query({
      query: listsEpicsQuery,
      context: {
        isSingleRequest: true,
      },
      variables,
    })
    .then(({ data }) => {
      const { lists } = data.group?.epicBoard;
      return { listItems: formatListEpics(lists), listPageInfo: formatEpicListsPageInfo(lists) };
    });
};

export default {
  ...actionsCE,

  setFilters: ({ commit, dispatch, getters }, filters) => {
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
      'myReactionEmoji',
    ]);

    // Temporarily disabled until negated filters are supported for epic boards
    if (!getters.isEpicBoard) {
      filterParams.not = transformNotFilters(filters);
    }

    if (filters.groupBy === GroupByParamType.epic) {
      dispatch('setEpicSwimlanes');
    }

    if (filterParams.epicId === EpicFilterType.any || filterParams.epicId === EpicFilterType.none) {
      filterParams.epicWildcardId = filterParams.epicId.toUpperCase();
      filterParams.epicId = undefined;
    } else if (filterParams.epicId) {
      filterParams.epicId = fullEpicId(filterParams.epicId);
    }
    if (!getters.isEpicBoard && filterParams.not.epicId) {
      filterParams.not.epicId = fullEpicId(filterParams.not.epicId);
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
      dispatch('fetchEpicsSwimlanes');
      dispatch('fetchIssueLists');
    } else if (gon.features.graphqlBoardLists || getters.isEpicBoard) {
      dispatch('fetchLists');
      dispatch('resetIssues');
    }
  },

  fetchEpicsSwimlanes({ state, commit, dispatch }, { endCursor = null } = {}) {
    const { fullPath, boardId, boardType, filterParams } = state;

    const variables = {
      fullPath,
      boardId: `gid://gitlab/Board/${boardId}`,
      issueFilters: filterParams,
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
        const { epics } = data[boardType]?.board;
        const epicsFormatted = epics.edges.map((e) => ({
          ...e.node,
        }));

        if (epicsFormatted) {
          commit(types.RECEIVE_EPICS_SUCCESS, {
            epics: epicsFormatted,
            canAdminEpic: epics.edges[0]?.node?.userPermissions?.adminEpic,
          });
          commit(types.UPDATE_CACHED_EPICS, epicsFormatted);
        }

        if (epics.pageInfo?.hasNextPage) {
          dispatch('fetchEpicsSwimlanes', {
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

  fetchItemsForList: (
    { state, commit, getters },
    { listId, fetchNext = false, noEpicIssues = false, forSwimlanes = false },
  ) => {
    commit(types.REQUEST_ITEMS_FOR_LIST, { listId, fetchNext });

    const { epicId, ...filterParams } = state.filterParams;
    if (noEpicIssues && epicId !== undefined) {
      return null;
    }
    if (forSwimlanes && epicId === undefined && filterParams.epicWildcardId === undefined) {
      filterParams.epicWildcardId = EpicFilterType.any.toUpperCase();
    }

    const variables = {
      id: listId,
      filters: noEpicIssues
        ? { ...filterParams, epicWildcardId: EpicFilterType.none.toUpperCase() }
        : { ...filterParams, epicId },
      after: fetchNext ? state.pageInfoByListId[listId].endCursor : undefined,
      first: forSwimlanes ? undefined : 20,
    };

    if (getters.isEpicBoard) {
      return fetchAndFormatListEpics(state, variables)
        .then(({ listItems, listPageInfo }) => {
          commit(types.RECEIVE_ITEMS_FOR_LIST_SUCCESS, {
            listItems,
            listPageInfo,
            listId,
            noEpicIssues,
          });
        })
        .catch(() => commit(types.RECEIVE_ITEMS_FOR_LIST_FAILURE, listId));
    }

    return fetchAndFormatListIssues(state, variables)
      .then(({ listItems, listPageInfo }) => {
        commit(types.RECEIVE_ITEMS_FOR_LIST_SUCCESS, {
          listItems,
          listPageInfo,
          listId,
          noEpicIssues,
        });
      })
      .catch(() => commit(types.RECEIVE_ITEMS_FOR_LIST_FAILURE, listId));
  },

  toggleEpicSwimlanes: ({ state, commit, dispatch }) => {
    commit(types.TOGGLE_EPICS_SWIMLANES);

    if (state.isShowingEpicsSwimlanes) {
      historyPushState(
        mergeUrlParams({ group_by: GroupByParamType.epic }, window.location.href, {
          spreadArrays: true,
        }),
      );
      dispatch('fetchEpicsSwimlanes');
      dispatch('fetchIssueLists');
    } else if (!gon.features.graphqlBoardLists) {
      historyPushState(removeParams(['group_by']), window.location.href, true);
      boardsStore.create();
      eventHub.$emit('initialBoardLoad');
    } else {
      historyPushState(removeParams(['group_by']), window.location.href, true);
    }
  },

  setEpicSwimlanes: ({ commit }) => {
    commit(types.SET_EPICS_SWIMLANES);
  },

  doneLoadingSwimlanesItems: ({ commit }) => {
    commit(types.DONE_LOADING_SWIMLANES_ITEMS);
  },

  resetEpics: ({ commit }) => {
    commit(types.RESET_EPICS);
  },

  fetchEpicForActiveIssue: async ({ state, commit, getters }) => {
    if (!getters.activeBoardItem.epic) {
      return false;
    }

    const {
      epic: { id, iid },
    } = getters.activeBoardItem;

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
          iid: String(getters.activeBoardItem.iid),
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
      commit(types.RECEIVE_EPICS_SUCCESS, { epics: [epic, ...state.epics] });
      commit(types.UPDATE_CACHED_EPICS, [epic]);
    }

    commit(typesCE.UPDATE_BOARD_ITEM_BY_ID, {
      itemId: getters.activeBoardItem.id,
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
          iid: String(getters.activeBoardItem.iid),
          weight: input.weight,
          projectPath: input.projectPath,
        },
      },
    });

    if (!data.issueSetWeight || data.issueSetWeight?.errors?.length > 0) {
      throw new Error(data.issueSetWeight?.errors);
    }

    commit(typesCE.UPDATE_BOARD_ITEM_BY_ID, {
      itemId: getters.activeBoardItem.id,
      prop: 'weight',
      value: data.issueSetWeight.issue.weight,
    });
  },

  moveItem: ({ getters, dispatch }, params) => {
    if (!getters.isEpicBoard) {
      dispatch('moveIssue', params);
    } else {
      dispatch('moveEpic', params);
    }
  },

  moveIssue: (
    { state, commit },
    { itemId, itemIid, itemPath, fromListId, toListId, moveBeforeId, moveAfterId, epicId },
  ) => {
    const originalIssue = state.boardItems[itemId];
    const fromList = state.boardItemsByListId[fromListId];
    const originalIndex = fromList.indexOf(Number(itemId));
    commit(types.MOVE_ISSUE, {
      originalIssue,
      fromListId,
      toListId,
      moveBeforeId,
      moveAfterId,
      epicId,
    });

    const { boardId } = state;
    const [fullProjectPath] = itemPath.split(/[#]/);

    gqlClient
      .mutate({
        mutation: issueMoveListMutation,
        variables: {
          projectPath: fullProjectPath,
          boardId: fullBoardId(boardId),
          iid: itemIid,
          fromListId: getIdFromGraphQLId(fromListId),
          toListId: getIdFromGraphQLId(toListId),
          moveBeforeId,
          moveAfterId,
          epicId,
        },
      })
      .then(({ data }) => {
        if (data?.issueMoveList?.errors.length) {
          throw new Error();
        } else {
          const issue = data.issueMoveList?.issue;
          commit(types.MOVE_ISSUE_SUCCESS, { issue });
        }
      })
      .catch(() =>
        commit(types.MOVE_ISSUE_FAILURE, { originalIssue, fromListId, toListId, originalIndex }),
      );
  },

  moveEpic: ({ state, commit }, { itemId, fromListId, toListId, moveBeforeId, moveAfterId }) => {
    const originalEpic = state.boardItems[itemId];
    const fromList = state.boardItemsByListId[fromListId];
    const originalIndex = fromList.indexOf(Number(itemId));
    commit(types.MOVE_EPIC, {
      originalEpic,
      fromListId,
      toListId,
      moveBeforeId,
      moveAfterId,
    });

    const { boardId } = state;

    gqlClient
      .mutate({
        mutation: epicMoveListMutation,
        variables: {
          epicId: fullEpicId(itemId),
          boardId: fullEpicBoardId(boardId),
          fromListId,
          toListId,
        },
      })
      .then(({ data }) => {
        if (data?.epicMoveList?.errors.length) {
          throw new Error();
        }
      })
      .catch(() =>
        commit(types.MOVE_EPIC_FAILURE, { originalEpic, fromListId, toListId, originalIndex }),
      );
  },

  fetchLists: ({ getters, dispatch }) => {
    if (!getters.isEpicBoard) {
      dispatch('fetchIssueLists');
    } else {
      dispatch('fetchEpicLists');
    }
  },

  fetchEpicLists: ({ commit, state }) => {
    const { filterParams, fullPath, boardId } = state;

    const variables = {
      fullPath,
      boardId: fullEpicBoardId(boardId),
      filters: filterParams,
    };

    return gqlClient
      .query({
        query: epicBoardListsQuery,
        variables,
      })
      .then(({ data }) => {
        const { lists } = data.group?.epicBoard;
        commit(types.RECEIVE_BOARD_LISTS_SUCCESS, formatBoardLists(lists));
      })
      .catch(() => commit(types.RECEIVE_BOARD_LISTS_FAILURE));
  },

  fetchMilestones({ state, commit }, searchTerm) {
    commit(types.RECEIVE_MILESTONES_REQUEST);

    const { fullPath, boardType } = state;

    const variables = {
      fullPath,
      searchTerm,
    };

    let query;
    if (boardType === BoardType.project) {
      query = projectBoardMilestonesQuery;
    }
    if (boardType === BoardType.group) {
      query = groupBoardMilestonesQuery;
    }

    if (!query) {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      throw new Error('Unknown board type');
    }

    return gqlClient
      .query({
        query,
        variables,
      })
      .then(({ data }) => {
        const errors = data[boardType]?.errors;
        const milestones = data[boardType]?.milestones.nodes;

        if (errors?.[0]) {
          throw new Error(errors[0]);
        }

        commit(types.RECEIVE_MILESTONES_SUCCESS, milestones);
      })
      .catch((e) => {
        commit(types.RECEIVE_MILESTONES_FAILURE);
        throw e;
      });
  },

  fetchIterations({ state, commit }, title) {
    commit(types.RECEIVE_ITERATIONS_REQUEST);

    const { fullPath, boardType } = state;

    const variables = {
      fullPath,
      title,
    };

    let query;
    if (boardType === BoardType.project) {
      query = projectBoardIterationsQuery;
    }
    if (boardType === BoardType.group) {
      query = groupBoardIterationsQuery;
    }

    if (!query) {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      throw new Error('Unknown board type');
    }

    return gqlClient
      .query({
        query,
        variables,
      })
      .then(({ data }) => {
        const errors = data[boardType]?.errors;
        const iterations = data[boardType]?.iterations.nodes;

        if (errors?.[0]) {
          throw new Error(errors[0]);
        }

        commit(types.RECEIVE_ITERATIONS_SUCCESS, iterations);
      })
      .catch((e) => {
        commit(types.RECEIVE_ITERATIONS_FAILURE);
        throw e;
      });
  },

  fetchAssignees({ state, commit }, search) {
    commit(types.RECEIVE_ASSIGNEES_REQUEST);

    const { fullPath, boardType } = state;

    const variables = {
      fullPath,
      search,
    };

    let query;
    if (boardType === BoardType.project) {
      query = projectBoardAssigneesQuery;
    }
    if (boardType === BoardType.group) {
      query = groupBoardAssigneesQuery;
    }

    if (!query) {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      throw new Error('Unknown board type');
    }

    return gqlClient
      .query({
        query,
        variables,
      })
      .then(({ data }) => {
        const [firstError] = data.workspace.errors || [];
        const assignees = data.workspace.assignees.nodes;

        if (firstError) {
          throw new Error(firstError);
        }
        commit(
          types.RECEIVE_ASSIGNEES_SUCCESS,
          assignees.map(({ user }) => user),
        );
      })
      .catch((e) => {
        commit(types.RECEIVE_ASSIGNEES_FAILURE);
        throw e;
      });
  },

  createList: (
    { getters, dispatch },
    { backlog, labelId, milestoneId, assigneeId, iterationId },
  ) => {
    if (!getters.isEpicBoard) {
      dispatch('createIssueList', { backlog, labelId, milestoneId, assigneeId, iterationId });
    } else {
      dispatch('createEpicList', { backlog, labelId });
    }
  },

  createEpicList: ({ state, commit, dispatch, getters }, { backlog, labelId }) => {
    const { boardId } = state;

    const existingList = getters.getListByLabelId(labelId);

    if (existingList) {
      dispatch('highlightList', existingList.id);
      return;
    }

    gqlClient
      .mutate({
        mutation: createEpicBoardListMutation,
        variables: {
          boardId: fullEpicBoardId(boardId),
          backlog,
          labelId,
        },
      })
      .then(({ data }) => {
        if (data?.epicBoardListCreate?.errors.length) {
          commit(types.CREATE_LIST_FAILURE, data.epicBoardListCreate.errors[0]);
        } else {
          const list = data.epicBoardListCreate?.list;
          dispatch('addList', list);
          dispatch('highlightList', list.id);
        }
      })
      .catch((e) => {
        commit(types.CREATE_LIST_FAILURE);
        throw e;
      });
  },

  setActiveBoardItemLabels: ({ getters, dispatch }, params) => {
    if (!getters.isEpicBoard) {
      dispatch('setActiveIssueLabels', params);
    } else {
      dispatch('setActiveEpicLabels', params);
    }
  },

  setActiveEpicLabels: async ({ commit, getters, state }, input) => {
    const { activeBoardItem } = getters;
    const { data } = await gqlClient.mutate({
      mutation: updateEpicLabelsMutation,
      variables: {
        input: {
          iid: String(activeBoardItem.iid),
          addLabelIds: input.addLabelIds ?? [],
          removeLabelIds: input.removeLabelIds ?? [],
          groupPath: state.fullPath,
        },
      },
    });

    if (data.updateEpic?.errors?.length > 0) {
      throw new Error(data.updateEpic.errors);
    }

    commit(typesCE.UPDATE_BOARD_ITEM_BY_ID, {
      itemId: activeBoardItem.id,
      prop: 'labels',
      value: data.updateEpic.epic.labels.nodes,
    });
  },
};
