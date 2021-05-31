import { sortBy, cloneDeep } from 'lodash';
import { filter } from 'vue/types/umd';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { ListType } from './constants';

export function getMilestone() {
  return null;
}

export function updateListPosition(listObj) {
  const { listType } = listObj;
  let { position } = listObj;
  if (listType === ListType.closed) {
    position = Infinity;
  } else if (listType === ListType.backlog) {
    position = -Infinity;
  }

  return { ...listObj, position };
}

export function formatBoardLists(lists) {
  return lists.nodes.reduce((map, list) => {
    return {
      ...map,
      [list.id]: updateListPosition(list),
    };
  }, {});
}

export function formatIssue(issue) {
  return {
    ...issue,
    labels: issue.labels?.nodes || [],
    assignees: issue.assignees?.nodes || [],
  };
}

export function formatListIssues(listIssues) {
  const boardItems = {};
  let listItemsCount;

  const listData = listIssues.nodes.reduce((map, list) => {
    listItemsCount = list.issues.count;
    let sortedIssues = list.issues.edges.map((issueNode) => ({
      ...issueNode.node,
    }));
    sortedIssues = sortBy(sortedIssues, 'relativePosition');

    return {
      ...map,
      [list.id]: sortedIssues.map((i) => {
        const id = getIdFromGraphQLId(i.id);

        const listIssue = {
          ...i,
          id,
          labels: i.labels?.nodes || [],
          assignees: i.assignees?.nodes || [],
        };

        boardItems[id] = listIssue;

        return id;
      }),
    };
  }, {});

  return { listData, boardItems, listItemsCount };
}

export function formatListsPageInfo(lists) {
  const listData = lists.nodes.reduce((map, list) => {
    return {
      ...map,
      [list.id]: list.issues.pageInfo,
    };
  }, {});
  return listData;
}

export function fullBoardId(boardId) {
  return `gid://gitlab/Board/${boardId}`;
}

export function fullIterationId(id) {
  return `gid://gitlab/Iteration/${id}`;
}

export function fullUserId(id) {
  return `gid://gitlab/User/${id}`;
}

export function fullMilestoneId(id) {
  return `gid://gitlab/Milestone/${id}`;
}

export function fullLabelId(label) {
  if (label.project_id && label.project_id !== null) {
    return `gid://gitlab/ProjectLabel/${label.id}`;
  }
  return `gid://gitlab/GroupLabel/${label.id}`;
}

export function formatIssueInput(issueInput, boardConfig) {
  const { labelIds = [], assigneeIds = [] } = issueInput;
  const { labels, assigneeId, milestoneId } = boardConfig;

  return {
    milestoneId: milestoneId ? fullMilestoneId(milestoneId) : null,
    ...issueInput,
    labelIds: [...labelIds, ...(labels?.map((l) => fullLabelId(l)) || [])],
    assigneeIds: [...assigneeIds, ...(assigneeId ? [fullUserId(assigneeId)] : [])],
  };
}

export function shouldCloneCard(fromListType, toListType) {
  const involvesClosed = fromListType === ListType.closed || toListType === ListType.closed;
  const involvesBacklog = fromListType === ListType.backlog || toListType === ListType.backlog;

  if (involvesClosed || involvesBacklog) {
    return false;
  }

  if (fromListType !== toListType) {
    return true;
  }

  return false;
}

export function getMoveData(state, params) {
  const { boardItems, boardItemsByListId, boardLists } = state;
  const { itemId, fromListId, toListId } = params;
  const fromListType = boardLists[fromListId].listType;
  const toListType = boardLists[toListId].listType;

  return {
    reordering: fromListId === toListId,
    shouldClone: shouldCloneCard(fromListType, toListType),
    itemNotInToList: !boardItemsByListId[toListId].includes(itemId),
    originalIssue: cloneDeep(boardItems[itemId]),
    originalIndex: boardItemsByListId[fromListId].indexOf(itemId),
    ...params,
  };
}

export function moveItemListHelper(item, fromList, toList) {
  const updatedItem = item;
  if (
    toList.listType === ListType.label &&
    !updatedItem.labels.find((label) => label.id === toList.label.id)
  ) {
    updatedItem.labels.push(toList.label);
  }
  if (fromList?.label && fromList.listType === ListType.label) {
    updatedItem.labels = updatedItem.labels.filter((label) => fromList.label.id !== label.id);
  }

  if (
    toList.listType === ListType.assignee &&
    !updatedItem.assignees.find((assignee) => assignee.id === toList.assignee.id)
  ) {
    updatedItem.assignees.push(toList.assignee);
  }
  if (fromList?.assignee && fromList.listType === ListType.assignee) {
    updatedItem.assignees = updatedItem.assignees.filter(
      (assignee) => assignee.id !== fromList.assignee.id,
    );
  }

  return updatedItem;
}

export function isListDraggable(list) {
  return list.listType !== ListType.backlog && list.listType !== ListType.closed;
}

// EE-specific feature. Find the implementation in the `ee/`-folder
export function transformBoardConfig() {
  return '';
}

export const FiltersInfo = {
  assigneeUsername: {
    negatedSupport: true,
  },
  assigneeId: {
    /**
     * TODO the API endpoint for the classic boards
     * accepts assignee wildcard value as 'assigneeId' param -
     * while the GraphQL query accepts the value in 'assigneWildcardId' field.
     * Once we deprecate the classics boards,
     * we should change the filtered search bar to use 'asssigneeWildcardId' as a token name.
     */
    transform: (val) => {
      return AssigneeIdParamValues.includes(val)
        ? {
            assigneeWildcardId: val.toUpperCase(),
          }
        : {};
    },
    negatedSupport: false,
  },
  authorUsername: {
    negatedSupport: true,
  },
  labelName: {
    negatedSupport: true,
  },
  milestoneTitle: {
    negatedSupport: true,
  },
  myReactionEmoji: {
    negatedSupport: true,
  },
  releaseTag: {
    negatedSupport: true,
  },
  search: {
    negatedSupport: false,
  },
};

// Example input/output
// - input: { search: "foobar", "not[authorUsername]": "root", }
// - output: [ ["search", "foobar", false], ["authorUsername", "root", true], ]
const parseFilters = (rawFilters) => {
  return rawFilters.keys().map((k) => {
    const f = rawFilters[k];
    const isNegated = (f) => f.slice(0, 4) === 'not[' && f.slice(-1) === ']';
    const filterKey = isNegated ? f.slice(4, -1) : f;

    return [filterKey, isNegated];
  });
};

const negateFilter = (k, v) => ({
  [`not[${k}]`]: v,
});

export const validFilters = (rawFilters, issuableType, FiltersInfo, ValidFilters) =>
  parseFilters(rawFilters)
    .filter(([k, _, isNegated]) => {
      const isValid = ValidFilters[issuableType].includes(f);
      if (isNegated) {
        return isValid && FiltersInfo[k].negatedSupport;
      }

      return isValid;
    })
    .map(([k, v, isNegated]) => {
      const filter = FiltersInfo[k].transform
        // If the filter needs a special transformation, apply it
        // e.g., if the filter uses a different name in a GraphQL request.
        ? FiltersInfo[k].transform(v)
        : {
            k: v,
          };

      return isNegated ? negateFilter(filter) : filter;
    })
    .reduce(
      (acc, cur) => ({
        ...acc,
        ...cur,
      }),
      {},
    );

export default {
  getMilestone,
  formatIssue,
  formatListIssues,
  fullBoardId,
  fullLabelId,
  fullIterationId,
  isListDraggable,
};
