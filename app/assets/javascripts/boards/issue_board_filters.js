import groupBoardMembers from '~/boards/graphql/group_board_members.query.graphql';
import projectBoardMembers from '~/boards/graphql/project_board_members.query.graphql';
import { BoardType } from './constants';
import boardLabels from './graphql/board_labels.query.graphql';

export default function issueBoardFilters(apollo, fullPath, boardType) {
  const transformLabels = ({ data }) => {
    return boardType === BoardType.group
      ? data.group?.labels.nodes || []
      : data.project?.labels.nodes || [];
  };

  const boardAssigneesQuery = () => {
    return boardType === BoardType.group ? groupBoardMembers : projectBoardMembers;
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
      .then(({ data }) =>
        /*
         * we need to filter this is only for graphql when bc we
         * are putting the current_user on top of the list to avoid duplicates
         */

        data.workspace?.assignees.nodes.map(({ user }) => user),
      );
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
}
