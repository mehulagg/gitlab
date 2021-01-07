import base from '~/boards/components/sidebar/remove_issue.vue';
import boardsStore from '~/boards/stores/boards_store';

export default {
  extends: base,
  methods: {
    seedPatchRequest(issue, req) {
      /* eslint-disable no-param-reassign */
      const board = boardsStore.state.currentBoard;
      const boardLabelIds = board.labels.map((label) => label.id);

      req.label_ids = req.label_ids.filter((id) => !boardLabelIds.includes(id));

      if (board.milestone_id) {
        req.milestone_id = -1;
      }

      if (board.weight) {
        req.weight = null;
      }

      const boardAssignee = board.assignee ? board.assignee.id : null;
      const assigneeIds = issue.assignees
        .map((assignee) => assignee.id)
        .filter((id) => id !== boardAssignee);

      return {
        ...req,
        assignee_ids: assigneeIds.length ? assigneeIds : ['0'],
      };
    },
  },
};
