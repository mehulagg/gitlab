import { getDurationChartData } from '../../../utils';

export const durationChartPlottableData = (state, _, rootState) => {
  const { createdAfter, createdBefore } = rootState;
  const { durationData } = state;
  const selectedStagesDurationData = durationData.filter((stage) => stage.selected);
  const plottableData = getDurationChartData(
    selectedStagesDurationData,
    createdAfter,
    createdBefore,
  );

  return plottableData.length ? plottableData : [];
};
