export default {
  methods: {
    buildUpdateRequest(list) {
      const { currentBoard } = this.state;
      const boardLabelIds = currentBoard.labels.map((label) => label.id);
      const assigneeIds = currentBoard.assignee && [currentBoard.assignee.id];

      return {
        add_label_ids: [list.label.id, ...boardLabelIds],
        milestone_id: currentBoard.milestone_id,
        assignee_ids: assigneeIds,
        weight: currentBoard.weight,
      };
    },
  },
};
