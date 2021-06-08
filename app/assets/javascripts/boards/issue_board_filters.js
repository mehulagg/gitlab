import groupBoardAssignees from 'ee_else_ce/boards/graphql/group_board_assignees.query.graphql'; // cannot resolve
import projectBoardAssignees from 'ee_else_ce/boards/graphql/project_board_assignees.query.graphql';
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
      .then(({ data }) => (
          /*
            * we need to filter this is only for graphql when bc we
            * are putting the current_user on top of the list to avoid duplicates
          */

          data.workspace?.assignees.nodes
            .map(({ user }) => user)
            .filter(({ username }) => username !== gon.current_username)
      ));
  };

  const fetchLabels = (labelSearchTerm) => {
    return apollo
      .query({
        query: boardLabels,
        variables: {
          fullPath,
          searchTerm: labelSearchTerm,
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
