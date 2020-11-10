import { getTasksByTypeData } from '../../../utils';

export const selectedTasksByTypeFilters = (state = {}, _, rootState = {}) => {
  const { selectedLabelIds = [], subject } = state;
  const { currentGroup, selectedProjectIds = [], startDate = null, endDate = null } = rootState;
  return {
    currentGroup,
    selectedProjectIds,
    startDate,
    endDate,
    selectedLabelIds,
    subject,
  };
};

export const tasksByTypeChartData = ({ data = [] } = {}, _, rootState = {}) => {
  const { startDate = null, endDate = null } = rootState;
  return data.length
    ? getTasksByTypeData({
        data,
        startDate,
        endDate,
      })
    : { groupBy: [], data: [] };
};
