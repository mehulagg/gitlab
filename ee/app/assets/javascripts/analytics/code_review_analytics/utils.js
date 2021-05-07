/**
 * Transforms a given filters object
 * into the following structure:
 * {
 *  selectedLabels: [{ value: 'foo', operator: ''}, { value: 'bar', operator: '!=' }],
 *  selectedMilestone: { value: 'milestone', operator: '='}
 * }
 *
 * @param {Object} filters
 * @returns {Object}
 */
const transformFilters = (filters) => {
  const {
    label_name: labelNames,
    milestone_title: milestoneTitle,
    'not[label_name]': notLabelNames,
    'not[milestone_title]': notMilestoneTitle,
  } = filters;

  let selectedLabels = labelNames?.map((label) => ({ value: label, operator: '=' })) || [];
  let selectedMilestone = null;

  if (notLabelNames) {
    selectedLabels = [
      ...selectedLabels,
      ...notLabelNames.map((label) => ({ value: label, operator: '!=' })),
    ];
  }

  if (milestoneTitle) {
    selectedMilestone = { value: milestoneTitle, operator: '=' };
  } else if (notMilestoneTitle) {
    selectedMilestone = { value: notMilestoneTitle, operator: '!=' };
  }

  return { selectedLabels, selectedMilestone };
};

export default transformFilters;
