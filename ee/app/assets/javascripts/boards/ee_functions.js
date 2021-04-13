export const setWeightFetchingState = (issue, value) => {
  issue.setFetchingState('weight', value);
};
export const setEpicFetchingState = (issue, value) => {
  issue.setFetchingState('epic', value);
};

export const getMilestoneTitle = ($boardApp) => ({
  milestoneTitle: $boardApp.dataset.boardMilestoneTitle,
});
