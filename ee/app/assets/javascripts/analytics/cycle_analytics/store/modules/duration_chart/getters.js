import { getDurationChartData } from '../../../utils';

export const durationChartPlottableData = (state, _, rootState) => {
  const { startDate, endDate } = rootState;
  const { durationData } = state;
  const selectedStagesDurationData = durationData.filter(stage => stage.selected);
  const plottableData = getDurationChartData(selectedStagesDurationData, startDate, endDate);

  return plottableData.length ? plottableData : [];
};
