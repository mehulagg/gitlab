import { sortBy } from 'lodash';
import axios from '~/lib/utils/axios_utils';
import { ListType } from './constants';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

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
  const issues = {};
  let listIssuesCount;

  const listData = listIssues.nodes.reduce((map, list) => {
    listIssuesCount = list.issues.count;
    let sortedIssues = list.issues.edges.map(issueNode => ({
      ...issueNode.node,
    }));
    sortedIssues = sortBy(sortedIssues, 'relativePosition');

    return {
      ...map,
      [list.id]: sortedIssues.map(i => {
        const id = getIdFromGraphQLId(i.id);

        const listIssue = {
          ...i,
          id,
          labels: i.labels?.nodes || [],
          assignees: i.assignees?.nodes || [],
        };

        issues[id] = listIssue;

        return id;
      }),
    };
  }, {});

  return { listData, issues, listIssuesCount };
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

export function fullLabelId(label) {
  if (label.project_id !== null) {
    return `gid://gitlab/ProjectLabel/${label.id}`;
  }
  return `gid://gitlab/GroupLabel/${label.id}`;
}

export function moveIssueListHelper(issue, fromList, toList) {
  const updatedIssue = issue;
  if (
    toList.listType === ListType.label &&
    !updatedIssue.labels.find(label => label.id === toList.label.id)
  ) {
    updatedIssue.labels.push(toList.label);
  }
  if (fromList?.label && fromList.listType === ListType.label) {
    updatedIssue.labels = updatedIssue.labels.filter(label => fromList.label.id !== label.id);
  }

  if (
    toList.listType === ListType.assignee &&
    !updatedIssue.assignees.find(assignee => assignee.id === toList.assignee.id)
  ) {
    updatedIssue.assignees.push(toList.assignee);
  }
  if (fromList?.assignee && fromList.listType === ListType.assignee) {
    updatedIssue.assignees = updatedIssue.assignees.filter(
      assignee => assignee.id !== fromList.assignee.id,
    );
  }

  return updatedIssue;
}

export function getBoardsPath(endpoint, board) {
  const path = `${endpoint}${board.id ? `/${board.id}` : ''}.json`;

  if (board.id) {
    return axios.put(path, { board });
  }
  return axios.post(path, { board });
}

export function isListDraggable(list) {
  return list.listType !== ListType.backlog && list.listType !== ListType.closed;
}

export default {
  getMilestone,
  formatIssue,
  formatListIssues,
  fullBoardId,
  fullLabelId,
  getBoardsPath,
  isListDraggable,
};
