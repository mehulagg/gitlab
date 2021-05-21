import groupBoardAssignees from 'ee/boards/graphql/group_board_assignees.query.graphql';
import projectBoardAssignees from 'ee/boards/graphql/project_board_assignees.query.graphql';
import { BoardType } from './constants';
import boardLabels from './graphql/board_labels.query.graphql';

export default (apollo, fullPath, boardType) => {
  const transformLabels = ({ data }) => {
    return boardType === BoardType.group
      ? data.group?.labels.nodes || []
      : data.project?.labels.nodes || [];
  };

  const boardAssigneesQuery = () => {
    return boardType === BoardType.group ? groupBoardAssignees : projectBoardAssignees;
  };

  const fetchAuthors = (authorsSearchTerm) => {
    return apollo
      .query({
        query: boardAssigneesQuery(),
        variables: {
          fullPath,
          search: authorsSearchTerm,
        },
      })
      .then(({ data }) => data.workspace?.assignees.nodes.map((item) => item.user));
  };

  const fetchLabels = (labelSearchTerm) => {
    return apollo
      .query({
        query: boardLabels,
        variables: {
          fullPath,
          search: labelSearchTerm,
          isGroup: boardType === BoardType.group,
          isProject: boardType === BoardType.project,
        },
      })
      .then(transformLabels);
  };

  return {
    fetchLabels,
    fetchAuthors,
  };
};
