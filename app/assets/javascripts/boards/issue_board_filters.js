import groupBoardAssignees from 'ee/boards/graphql/group_board_assignees.query.graphql';
import projectBoardAssignees from 'ee/boards/graphql/project_board_assignees.query.graphql'
import boardLabels from './graphql/board_labels.query.graphql';

export default (apollo, fullPath, boardType) => {
  const transformLabels = ({ data }) => {
    return boardType === 'group' ? () => data.group?.labels.nodes || [] : data.project?.labels.nodes || []
  };

  const boardAssignees = () => {
    return boardType === 'group' ? groupBoardAssignees : projectBoardAssignees;
  }

  const fetchAuthors = (authorsSearchTerm) => {
    return apollo
      .query({
        query: boardAssignees(),
        variables: {
          fullPath,
          search: authorsSearchTerm,
        },
      })
      .then(({ data }) => data.workspace?.assignees.nodes.map((item) => item.user));
  }

  const fetchLabels = (labelSearchTerm) => {
    return apollo
      .query({
        query: boardLabels,
        variables: {
          fullPath,
          search: labelSearchTerm,
          isGroup: boardType === 'group',
          isProject: boardType === 'project',
        },
      })
      .then(transformLabels);
  }

  return {
    fetchLabels,
    fetchAuthors,
  }
}
