import flash from '~/flash';
import { s__ } from '~/locale';
import Api from 'ee/api';
import axios from '~/lib/utils/axios_utils';
import httpStatusCodes from '~/lib/utils/http_status';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

import {
  addRelatedIssueErrorMap,
  pathIndeterminateErrorMap,
  relatedIssuesRemoveErrorMap,
} from 'ee/related_issues/constants';

import { processQueryResponse, formatChildItem, gqClient } from '../utils/epic_utils';
import { ActionType, ChildType, ChildState } from '../constants';

import epicChildren from '../queries/epicChildren.query.graphql';
import epicChildReorder from '../queries/epicChildReorder.mutation.graphql';

import * as types from './mutation_types';

export const setInitialConfig = ({ commit }, data) => commit(types.SET_INITIAL_CONFIG, data);

export const setInitialParentItem = ({ commit }, data) =>
  commit(types.SET_INITIAL_PARENT_ITEM, data);

export const setChildrenCount = ({ commit, state }, { children, isRemoved = false }) => {
  const [epicsCount, issuesCount] = children.reduce(
    (acc, item) => {
      if (item.type === ChildType.Epic) {
        acc[0] += isRemoved ? -1 : 1;
      } else {
        acc[1] += isRemoved ? -1 : 1;
      }
      return acc;
    },
    [state.epicsCount || 0, state.issuesCount || 0],
  );

  commit(types.SET_CHILDREN_COUNT, { epicsCount, issuesCount });
};

export const expandItem = ({ commit }, data) => commit(types.EXPAND_ITEM, data);
export const collapseItem = ({ commit }, data) => commit(types.COLLAPSE_ITEM, data);

export const setItemChildren = (
  { commit, dispatch },
  { parentItem, children, isSubItem, append = false },
) => {
  commit(types.SET_ITEM_CHILDREN, {
    parentItem,
    children,
    isSubItem,
    append,
  });

  dispatch('setChildrenCount', { children });

  if (isSubItem) {
    dispatch('expandItem', {
      parentItem,
    });
  }
};
export const setItemChildrenFlags = ({ commit }, data) =>
  commit(types.SET_ITEM_CHILDREN_FLAGS, data);

export const setEpicPageInfo = ({ commit }, data) => commit(types.SET_EPIC_PAGE_INFO, data);
export const setIssuePageInfo = ({ commit }, data) => commit(types.SET_ISSUE_PAGE_INFO, data);

export const requestItems = ({ commit }, data) => commit(types.REQUEST_ITEMS, data);
export const receiveItemsSuccess = ({ commit }, data) => commit(types.RECEIVE_ITEMS_SUCCESS, data);
export const receiveItemsFailure = ({ commit }, data) => {
  flash(s__('Epics|Something went wrong while fetching child epics.'));
  commit(types.RECEIVE_ITEMS_FAILURE, data);
};
export const fetchItems = ({ dispatch }, { parentItem, isSubItem = false }) => {
  const { iid, fullPath } = parentItem;

  dispatch('requestItems', {
    parentItem,
    isSubItem,
  });

  gqClient
    .query({
      query: epicChildren,
      variables: { iid, fullPath },
    })
    .then(({ data }) => {
      const children = processQueryResponse(data.group);

      dispatch('receiveItemsSuccess', {
        parentItem,
        children,
        isSubItem,
      });

      dispatch('setItemChildren', {
        parentItem,
        children,
        isSubItem,
      });

      dispatch('setItemChildrenFlags', {
        children,
        isSubItem,
      });

      dispatch('setEpicPageInfo', {
        parentItem,
        pageInfo: data.group.epic.children.pageInfo,
      });

      dispatch('setIssuePageInfo', {
        parentItem,
        pageInfo: data.group.epic.issues.pageInfo,
      });
    })
    .catch(() => {
      dispatch('receiveItemsFailure', {
        parentItem,
        isSubItem,
      });
    });
};

export const receiveNextPageItemsFailure = () => {
  flash(s__('Epics|Something went wrong while fetching child epics.'));
};
export const fetchNextPageItems = ({ dispatch, state }, { parentItem, isSubItem = false }) => {
  const { iid, fullPath } = parentItem;
  const parentItemFlags = state.childrenFlags[parentItem.reference];
  const variables = { iid, fullPath };

  if (parentItemFlags.hasMoreEpics) {
    variables.epicEndCursor = parentItemFlags.epicEndCursor;
  }

  if (parentItemFlags.hasMoreIssues) {
    variables.issueEndCursor = parentItemFlags.issueEndCursor;
  }

  return gqClient
    .query({
      query: epicChildren,
      variables,
    })
    .then(({ data }) => {
      const { epic } = data.group;
      const emptyChildren = { edges: [], pageInfo: epic.children.pageInfo };
      const emptyIssues = { edges: [], pageInfo: epic.issues.pageInfo };

      // Ensure we don't re-render already existing items
      const children = processQueryResponse({
        epic: {
          children: parentItemFlags.hasMoreEpics ? epic.children : emptyChildren,
          issues: parentItemFlags.hasMoreIssues ? epic.issues : emptyIssues,
        },
      });

      dispatch('setItemChildren', {
        parentItem,
        children,
        isSubItem,
        append: true,
      });

      dispatch('setItemChildrenFlags', {
        children,
        isSubItem: false,
      });

      dispatch('setEpicPageInfo', {
        parentItem,
        pageInfo: data.group.epic.children.pageInfo,
      });

      dispatch('setIssuePageInfo', {
        parentItem,
        pageInfo: data.group.epic.issues.pageInfo,
      });
    })
    .catch(() => {
      dispatch('receiveNextPageItemsFailure', {
        parentItem,
      });
    });
};

export const toggleItem = ({ state, dispatch }, { parentItem }) => {
  if (!state.childrenFlags[parentItem.reference].itemExpanded) {
    if (!state.children[parentItem.reference]) {
      dispatch('fetchItems', {
        parentItem,
        isSubItem: true,
      });
    } else {
      dispatch('expandItem', {
        parentItem,
      });
    }
  } else {
    dispatch('collapseItem', {
      parentItem,
    });
  }
};

export const setRemoveItemModalProps = ({ commit }, data) =>
  commit(types.SET_REMOVE_ITEM_MODAL_PROPS, data);
export const requestRemoveItem = ({ commit }, data) => commit(types.REQUEST_REMOVE_ITEM, data);
export const receiveRemoveItemSuccess = ({ commit }, data) =>
  commit(types.RECEIVE_REMOVE_ITEM_SUCCESS, data);
export const receiveRemoveItemFailure = ({ commit }, { item, status }) => {
  commit(types.RECEIVE_REMOVE_ITEM_FAILURE, item);
  flash(
    status === httpStatusCodes.NOT_FOUND
      ? pathIndeterminateErrorMap[ActionType[item.type]]
      : relatedIssuesRemoveErrorMap[ActionType[item.type]],
  );
};
export const removeItem = ({ dispatch }, { parentItem, item }) => {
  dispatch('requestRemoveItem', {
    item,
  });

  axios
    .delete(item.relationPath)
    .then(() => {
      dispatch('receiveRemoveItemSuccess', {
        parentItem,
        item,
      });

      dispatch('setChildrenCount', { children: [item], isRemoved: true });
    })
    .catch(({ status }) => {
      dispatch('receiveRemoveItemFailure', {
        item,
        status,
      });
    });
};

export const toggleAddItemForm = ({ commit }, data) => commit(types.TOGGLE_ADD_ITEM_FORM, data);
export const toggleCreateEpicForm = ({ commit }, data) =>
  commit(types.TOGGLE_CREATE_EPIC_FORM, data);

export const setPendingReferences = ({ commit }, data) =>
  commit(types.SET_PENDING_REFERENCES, data);
export const addPendingReferences = ({ commit }, data) =>
  commit(types.ADD_PENDING_REFERENCES, data);
export const removePendingReference = ({ commit }, data) =>
  commit(types.REMOVE_PENDING_REFERENCE, data);
export const setItemInputValue = ({ commit }, data) => commit(types.SET_ITEM_INPUT_VALUE, data);

export const requestAddItem = ({ commit }) => commit(types.REQUEST_ADD_ITEM);
export const receiveAddItemSuccess = ({ dispatch, commit, getters }, { actionType, rawItems }) => {
  const isEpic = actionType === ActionType.Epic;
  const items = rawItems.map(item =>
    formatChildItem({
      ...convertObjectPropsToCamelCase(item, { deep: !isEpic }),
      type: isEpic ? ChildType.Epic : ChildType.Issue,
      userPermissions: isEpic ? { adminEpic: item.can_admin } : {},
    }),
  );

  commit(types.RECEIVE_ADD_ITEM_SUCCESS, {
    insertAt: isEpic ? 0 : getters.issuesBeginAtIndex,
    items,
  });

  dispatch('setChildrenCount', { children: items });

  dispatch('setItemChildrenFlags', {
    children: items,
    isSubItem: false,
  });

  dispatch('setPendingReferences', []);
  dispatch('setItemInputValue', '');
  dispatch('toggleAddItemForm', {
    actionType,
    toggleState: false,
  });
};
export const receiveAddItemFailure = ({ commit, state }, data = {}) => {
  commit(types.RECEIVE_ADD_ITEM_FAILURE);

  let errorMessage = addRelatedIssueErrorMap[state.actionType];
  if (data.message) {
    errorMessage = data.message;
  }
  flash(errorMessage);
};
export const addItem = ({ state, dispatch }) => {
  dispatch('requestAddItem');

  axios
    .post(state.actionType === ActionType.Epic ? state.epicsEndpoint : state.issuesEndpoint, {
      issuable_references: state.pendingReferences,
    })
    .then(({ data }) => {
      dispatch('receiveAddItemSuccess', {
        actionType: state.actionType,
        // Newly added item is always first in the list
        rawItems: data.issuables.slice(0, state.pendingReferences.length),
      });
    })
    .catch(({ data }) => {
      dispatch('receiveAddItemFailure', data);
    });
};

export const requestCreateItem = ({ commit }) => commit(types.REQUEST_CREATE_ITEM);
export const receiveCreateItemSuccess = (
  { state, commit, dispatch, getters },
  { actionType, rawItem },
) => {
  const isEpic = actionType === ActionType.Epic;
  const item = formatChildItem({
    ...convertObjectPropsToCamelCase(rawItem, { deep: !isEpic }),
    type: isEpic ? ChildType.Epic : ChildType.Issue,
    // This is needed since Rails API to create Epic
    // doesn't return global ID, we can remove this
    // change once create epic action is moved to
    // GraphQL.
    id: `gid://gitlab/Epic/${rawItem.id}`,
    reference: `${state.parentItem.fullPath}${rawItem.reference}`,
  });

  commit(types.RECEIVE_CREATE_ITEM_SUCCESS, {
    insertAt: getters.issuesBeginAtIndex > 0 ? getters.issuesBeginAtIndex - 1 : 0,
    item,
  });

  dispatch('setChildrenCount', { children: [item] });

  dispatch('setItemChildrenFlags', {
    children: [item],
    isSubItem: false,
  });

  dispatch('toggleCreateEpicForm', {
    actionType,
    toggleState: false,
  });
};
export const receiveCreateItemFailure = ({ commit }) => {
  commit(types.RECEIVE_CREATE_ITEM_FAILURE);
  flash(s__('Epics|Something went wrong while creating child epics.'));
};
export const createItem = ({ state, dispatch }, { itemTitle }) => {
  dispatch('requestCreateItem');

  Api.createChildEpic({
    groupId: state.parentItem.fullPath,
    parentEpicIid: state.parentItem.iid,
    title: itemTitle,
  })
    .then(({ data }) => {
      Object.assign(data, {
        // TODO: API response is missing these 3 keys.
        // Once support is added, we need to remove it from here.
        path: data.url ? `/groups/${data.url.split('/groups/').pop()}` : '',
        state: ChildState.Open,
        created_at: '',
      });

      dispatch('receiveCreateItemSuccess', {
        actionType: state.actionType,
        rawItem: data,
      });
    })
    .catch(() => {
      dispatch('receiveCreateItemFailure');
    });
};

export const receiveReorderItemFailure = ({ commit }, data) => {
  commit(types.REORDER_ITEM, data);
  flash(s__('Epics|Something went wrong while ordering item.'));
};
export const reorderItem = (
  { dispatch, commit },
  { treeReorderMutation, parentItem, targetItem, oldIndex, newIndex },
) => {
  // We proactively update the store to reflect new order of item
  commit(types.REORDER_ITEM, { parentItem, targetItem, oldIndex, newIndex });

  return gqClient
    .mutate({
      mutation: epicChildReorder,
      variables: {
        epicTreeReorderInput: {
          baseEpicId: parentItem.id,
          moved: treeReorderMutation,
        },
      },
    })
    .then(({ data }) => {
      // Mutation was unsuccessful;
      // revert to original order and show flash error
      if (data.epicTreeReorder.errors.length) {
        dispatch('receiveReorderItemFailure', {
          parentItem,
          targetItem,
          oldIndex: newIndex,
          newIndex: oldIndex,
        });
      }
    })
    .catch(() => {
      // Mutation was unsuccessful;
      // revert to original order and show flash error
      dispatch('receiveReorderItemFailure', {
        parentItem,
        targetItem,
        oldIndex: newIndex,
        newIndex: oldIndex,
      });
    });
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
